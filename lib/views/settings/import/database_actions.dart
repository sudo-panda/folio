import 'dart:developer' as dev;

import 'package:folio/helpers/database.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/state/globals.dart';
import 'package:html/parser.dart' as html;
import 'package:sqflite/sqflite.dart';
import 'package:html/dom.dart';

class DatabaseActions {
  static Db db = Db();

  static Future<DateTime> getRecentDate() async {
    List<Map> tuples = await Db().getLimitedOrdered(
      Db.tblTradeLog,
      1,
      '${Db.colDate} DESC',
    );

    return tuples.isEmpty ? null : TradeLog.fromDbTuple(tuples.first).date;
  }

  static Future<bool> setTradeLog(
    String code,
    String exchange,
    String date,
    bool bought,
    int qty,
    double rate,
  ) async {
    String where, codeCol;
    if (exchange == "BSE") {
      where = "${Db.colBSECode} = ?";
      codeCol = Db.colBSECode;
    } else if (exchange == "NSE") {
      where = "${Db.colNSECode} = ?";
      codeCol = Db.colNSECode;
    }
    List<Map> tuples = await Db().getQuery(Db.tblPortfolio, where, [code]);
    if (tuples.length > 1) {
      return false;
    } else if (tuples.length == 0) {
      bool res = await Db().insert(Db.tblPortfolio, {codeCol: code});
      if (!res) return res;
      tuples = await Db().getQuery(Db.tblPortfolio, where, [code]);
    }
    
    if (!(await Db().insert(
      Db.tblTradeLog,
      {
        Db.colStockID: tuples.first[Db.colRowID],
        Db.colCode: code,
        Db.colExch: exchange,
        Db.colQty: qty,
        Db.colRate: rate,
        Db.colDate: date,
        Db.colBought: bought ? 1 : 0,
      },
    ))) {
      return false;
    }

    if (!(await updatePortfolioFigures(tuples.first[Db.colRowID]))) {
      return false;
    }

    tuples = await Db().getQuery(Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?', [code, exchange]);

    if (tuples.length == 0) {
      return await Db().insert(Db.tblTracked, {
        Db.colCode: code,
        Db.colExch: exchange,
        Db.colPinned: 0,
      });
    } else {
      return true;
    }
  }

  static Future<bool> updatePortfolioFigures(int rowID) async {
    var buyLogs = await DatabaseActions.getBuyLogs(rowID);
    var sellLogs = await DatabaseActions.getSellLogs(rowID);

    int qty;
    double msr;
    double esr;

    int b = 0, s = 0;
    double totalNet = 0, totalProfitDifference = 0;

    while (s < sellLogs.length) {
      int buyQty = sellLogs[s].qty;
      double avgBuyRate = 0.0;

      // calculate avgBuyRate for the sold stocks
      while (buyQty > 0) {
        if (b >= buyLogs.length || sellLogs[s].date.isBefore(buyLogs[b].date)) {
          await Db().updateConditionally(
            Db.tblPortfolio,
            {
              Db.colQty: qty,
              Db.colMSR: msr,
              Db.colESR: esr,
            },
            '${Db.colRowID} = ?',
            [rowID],
          );
          return false;
        }

        if (buyLogs[b].qty > buyQty) {
          buyLogs[b].qty -= buyQty;
          avgBuyRate = (avgBuyRate * (sellLogs[s].qty - buyQty) +
                  buyQty * buyLogs[b].rate) /
              sellLogs[s].qty;
          buyQty = 0;
        } else {
          avgBuyRate = (avgBuyRate * (sellLogs[s].qty - buyQty) +
                  buyLogs[b].qty * buyLogs[b].rate) /
              (sellLogs[s].qty - buyQty + buyLogs[b].qty);
          buyQty -= buyLogs[b].qty;
          buyLogs[b].qty = 0;
          b++;
        }
      }

      // calculate the Costs
      var avgBuyCost = avgBuyRate + avgBuyRate * Globals.brokerage;
      var avgSellCost = sellLogs[s].rate - sellLogs[s].rate * Globals.brokerage;

      totalNet += sellLogs[s].qty * (avgSellCost - avgBuyCost);
      // Does let past profits balance out future losses
      totalNet = totalNet > 0 ? 0 : totalNet;

      var estimatedSellRate = avgBuyCost + avgBuyCost * Globals.requiredProfit;
      totalProfitDifference +=
          sellLogs[s].qty * (avgSellCost - estimatedSellRate);

      // Uncomment if you want overall profit to be greater than requiredProfit
      totalProfitDifference =
          totalProfitDifference > 0 ? 0 : totalProfitDifference;

      s++;
    }

    qty = 0;
    msr = 0;
    esr = 0;

    double avgBuyRate = 0;

    for (; b < buyLogs.length; b++) {
      avgBuyRate = (qty * avgBuyRate + buyLogs[b].qty * buyLogs[b].rate) /
          (qty + buyLogs[b].qty);
      qty += buyLogs[b].qty;
    }

    if (qty != 0) {
      var avgBuyCost = avgBuyRate + avgBuyRate * Globals.brokerage;
      msr = ((avgBuyCost * qty - totalNet) / qty) * (1 + Globals.brokerage);

      var profitableSellRate = avgBuyCost + avgBuyCost * Globals.requiredProfit;
      esr = ((profitableSellRate * qty - totalProfitDifference) / qty) *
          (1 + Globals.brokerage);
    } else {
      msr = null;
      esr = null;
    }

    bool res = await Db().updateConditionally(
      Db.tblPortfolio,
      {
        Db.colQty: qty,
        Db.colMSR: msr,
        Db.colESR: esr,
      },
      '${Db.colRowID} = ?',
      [rowID],
    );

    return res;
  }

  static Future<List<TradeLog>> getBuyLogs(int stockID) async {
    List<Map> tuples = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colStockID} = ?',
      [1, stockID],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> buyLogs = [];
    tuples.forEach((element) {
      buyLogs.add(TradeLog.fromDbTuple(element));
    });
    return buyLogs;
  }

  static Future<List<TradeLog>> getSellLogs(int stockID) async {
    List<Map> tuples = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colStockID} = ?',
      [0, stockID],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> sellLogs = [];
    tuples.forEach((element) {
      sellLogs.add(TradeLog.fromDbTuple(element));
    });
    return sellLogs;
  }

  static Future<int> getRowIDAfterSettingCodes(String bseCode, nseCode) async {
    List<Map> tuples = await Db().getQuery(Db.tblPortfolio,
        '${Db.colBSECode} = ? or ${Db.colNSECode} = ?', [bseCode, nseCode]);
    if (tuples.length == 0) {
      Db().insert(
        Db.tblPortfolio,
        {
          Db.colBSECode: bseCode,
          Db.colNSECode: nseCode,
        },
      );
    } else if (tuples.length == 1) {
      Db().updateConditionally(
        Db.tblPortfolio,
        {
          Db.colBSECode: bseCode,
          Db.colNSECode: nseCode,
        },
        '${Db.colBSECode} = ? or ${Db.colNSECode} = ?',
        [bseCode, nseCode],
      );
      return tuples.first[Db.colRowID];
    } else {
      Db().deleteQuery(
        Db.tblPortfolio,
        '${Db.colBSECode} = ? or ${Db.colNSECode} = ?',
        [bseCode, nseCode],
      );
      Db().insert(
        Db.tblPortfolio,
        {
          Db.colBSECode: bseCode,
          Db.colNSECode: nseCode,
        },
      );
    }

    tuples = await Db().getQuery(Db.tblPortfolio,
        '${Db.colBSECode} = ? or ${Db.colNSECode} = ?', [bseCode, nseCode]);
    return tuples.first[Db.colRowID];
  }

  static Future<bool> linkCodes(Map<String, String> codes) async {
    int id = await getRowIDAfterSettingCodes(codes["BSE"], codes["NSE"]);

    bool res = await Db().updateConditionally(
      Db.tblTradeLog,
      {
        Db.colStockID: id,
      },
      '${Db.colCode} = ? or ${Db.colCode} = ?',
      [
        codes["BSE"],
        codes["NSE"],
      ],
    );

    if (!res) return false;

    return await updatePortfolioFigures(id);
  }

  static Future<List<TradeLog>> parseSBIFile(String file) async {
    Document parsedHTML = html.parse(file);
    List<String> headers = [];

    for (var cell in parsedHTML
        .querySelector("#grdViewTradeDetail")
        .querySelectorAll("tr")
        .first
        .querySelectorAll("th")) {
      headers.add(cell.innerHtml);
    }

    List<TradeLog> logs = [];

    for (var row in parsedHTML
        .querySelector("#grdViewTradeDetail")
        .querySelectorAll("tr")
        .skip(1)) {
      DateTime date;
      String exchange, code, scripCode, scripName;
      int buyQty = 0, sellQty = 0;
      double buyRate = 0, sellRate = 0;

      int i = 0;
      for (var cell in row.querySelectorAll("td")) {
        switch (headers[i]) {
          case "Date":
            date = DateTime.utc(
                int.parse(cell.innerHtml
                    .substring(cell.innerHtml.lastIndexOf('/') + 1)),
                int.parse(cell.innerHtml.substring(
                    cell.innerHtml.indexOf('/') + 1,
                    cell.innerHtml.lastIndexOf('/'))),
                int.parse(
                    cell.innerHtml.substring(0, cell.innerHtml.indexOf('/'))));
            break;
          case "Exch":
            exchange = cell.innerHtml.trim();
            break;
          case "Scrip Code":
            scripCode = cell.innerHtml.substring(1).trim();
            break;
          case "Scrip Name":
            scripName = html
                .parse(html.parse(cell.innerHtml).body.text)
                .documentElement
                .text
                .trim();
            break;
          case "Buy Qty":
            buyQty = int.parse(cell.innerHtml.trim());
            break;
          case "Sold Qty":
            sellQty = int.parse(cell.innerHtml.trim());
            break;
          case "Buy Rate":
            buyRate = double.parse(cell.innerHtml.trim());
            break;
          case "Sold Rate":
            sellRate = double.parse(cell.innerHtml.trim());
            break;
          default:
            break;
        }
        i++;
      }
      switch (exchange) {
        case "BSE":
          code = scripCode;
          break;
        case "NSE":
          code = scripName;
          break;
      }
      int id =
          await DatabaseActions.getRowIDAfterSettingCodes(scripCode, scripName);
      if (buyQty > 0)
        logs.add(TradeLog(date, id, code, exchange, true, buyQty, buyRate));

      if (sellQty > 0)
        logs.add(TradeLog(date, id, code, exchange, false, sellQty, sellRate));
    }

    return logs;
  }

  static Future<bool> addTradeLogs(List<TradeLog> logs) async {
    Set updateLater = Set();

    return await Db().transact((txn) async {
      int i = 0;
      for (var log in logs) {
        if (++i % 10 == 0) {
          dev.log("Added " + i.toString() + " logs to DB");
        }
        try {
          await txn.insert(Db.tblTradeLog, log.toDbTuple());
          await txn.insert(Db.tblTracked, {
            Db.colCode: log.code,
            Db.colExch: log.exchange,
            Db.colPinned: 0,
          });
          updateLater.add(log.id);
        } on DatabaseException catch (e) {
          if (e.isUniqueConstraintError()) {
            continue;
          } else {
            throw e;
          }
        }
      }
    }).then((value) async {
      for (var id in updateLater) {
        await updatePortfolioFigures(id);
      }
      return value;
    });
  }
}
