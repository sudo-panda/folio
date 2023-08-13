import 'dart:developer' as dev;

import 'package:csv/csv_settings_autodetection.dart';
import 'package:folio/services/database/database.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/models/database/portfolio.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/state/globals.dart';

import 'package:html/parser.dart' as html;
import 'package:sqflite/sqflite.dart';
import 'package:html/dom.dart';
import 'package:csv/csv.dart';

class DatabaseActions {
  static Future<List<TradeLog>> getAllLogs() async {
    List<Map<String, dynamic>> tuples = await Db()
        .getOrdered(Db.tblTradeLog, '${Db.colDate} DESC, ${Db.colCode} ASC');

    List<TradeLog> logs = [];
    tuples.forEach((row) => logs.add(TradeLog.fromDbTuple(row)));
    return logs;
  }

  static Future<List<Portfolio>> getAllPortfolios() async {
    List<Map<String, dynamic>> tuples = await Db().getOrdered(
        Db.tblPortfolio, '${Db.colNSECode} DESC, ${Db.colBSECode} DESC');

    List<Portfolio> portfolio = [];
    tuples.forEach((row) => portfolio.add(Portfolio.fromDbTuple(row)));
    return portfolio;
  }

  static Future<DateTime?> getRecentDate() async {
    List<Map<String, dynamic>> tuples = await Db().getLimitedOrdered(
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
    String where = "", codeCol = "";
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

    int qty = 0;
    double? msr;
    double? esr;

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
          var portfolio = await Db().getQuery(
            Db.tblPortfolio,
            '${Db.colRowID} = ?',
            [rowID],
          );
          await Db().deleteQuery(
            Db.tblTracked,
            '${Db.colCode} = ? and ${Db.colExch} = ?',
            [portfolio.first[Db.colBSECode], "BSE"],
          );

          await Db().deleteQuery(
            Db.tblTracked,
            '${Db.colCode} = ? and ${Db.colExch} = ?',
            [portfolio.first[Db.colNSECode], "NSE"],
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
      var portfolio = await Db().getQuery(
        Db.tblPortfolio,
        '${Db.colRowID} = ?',
        [rowID],
      );
      await Db().deleteQuery(
        Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?',
        [portfolio.first[Db.colBSECode], "BSE"],
      );

      await Db().deleteQuery(
        Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?',
        [portfolio.first[Db.colNSECode], "NSE"],
      );
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
    List<Map<String, dynamic>> tuples = await Db().getOrderedQuery(
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
    List<Map<String, dynamic>> tuples = await Db().getOrderedQuery(
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

  static Future<int> getRowIDAfterSettingCodes(String? bseCode, String? nseCode) async {
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
    int id = await getRowIDAfterSettingCodes(codes["BSE"]!, codes["NSE"]);

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

  static Future<List<TradeLog>?> parseSBIFile(String file) async {
    int mode = 0;
    Document parsedHTML = html.parse(file);
    List<String> headers = [];

    // dev.log(parsedHTML.outerHtml);

    Element? table = parsedHTML.querySelector("#grdViewTradeDetail");

    if (table == null) {
      table = parsedHTML.querySelector("#grdViewTradeDetail_old");
      mode = 1;
    }

    if (table == null) return null;

    for (var cell
        in table.querySelectorAll("tr").first.querySelectorAll("th")) {
      headers.add(cell.innerHtml);
    }

    List<TradeLog> logs = [];

    for (var row in table.querySelectorAll("tr").skip(1)) {
      late DateTime date;
      String exchange = "";
      String? scripCode, scripName, code;
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
            scripCode = cell.innerHtml.trim();
            if (scripCode.startsWith("E")) scripCode = scripCode.substring(1);
            break;
          case "Scrip Name":
            scripName = html
                .parse(html.parse(cell.innerHtml).body?.text)
                .documentElement
                !.text
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
        default:
          code = null;
      }

      if (code == null) continue;

      int id =
          await DatabaseActions.getRowIDAfterSettingCodes(scripCode, scripName);
      if (buyQty > 0)
        logs.add(TradeLog(date, id, code, exchange, true, buyQty, buyRate));

      if (sellQty > 0)
        logs.add(TradeLog(date, id, code, exchange, false, sellQty, sellRate));
    }

    return logs;
  }

  static Future<List<TradeLog>> parseCSVFile(String file) async {
    var detector = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    List<List<dynamic>> trades =
        const CsvToListConverter().convert(file, csvSettingsDetector: detector);

    List<TradeLog> logs = [];

    for (var row in trades.skip(1)) {
      late DateTime date;
      String exchange = "";
      String? code, bseCode, nseCode;
      int qty = 0;
      double rate = 0;
      bool bought = false;

      int i = 0;
      for (var element in row) {
        switch (trades.first[i]) {
          case "Date":
            date = DateTime.utc(
              int.parse(
                element.substring(
                  0,
                  element.indexOf('-'),
                ),
              ),
              int.parse(
                element.substring(
                  element.indexOf('-') + 1,
                  element.lastIndexOf('-'),
                ),
              ),
              int.parse(
                element.substring(element.lastIndexOf('-') + 1),
              ),
            );
            break;
          case "Exchange":
            exchange = element;
            break;
          case "BSE Code":
            bseCode = element.toString();
            break;
          case "NSE Code":
            nseCode = element.toString();
            break;
          case "Quantity":
            qty = int.parse(element.toString());
            break;
          case "Rate":
            rate = double.parse(element.toString());
            break;
          case "BUY/SELL":
            switch (element) {
              case "BUY":
                bought = true;
                break;
              case "SELL":
                bought = false;
                break;
            }
            break;
          default:
            break;
        }
        i++;
      }
      switch (exchange) {
        case "BSE":
          code = bseCode;
          break;
        case "NSE":
          code = nseCode;
          break;
      }
      print("Codes:- BSE: $bseCode \t NSE: $nseCode \t Exch: $exchange \n");
      if (code == null) continue;

      try {
        int id =
            await DatabaseActions.getRowIDAfterSettingCodes(bseCode, nseCode);

        if (qty > 0)
          logs.add(TradeLog(date, id, code, exchange, bought, qty, rate));
      } catch (e) {
        dev.log("parseCSVFile() => \n" + e.toString());
      }
    }

    return logs;
  }

  static Future<Object?> addTradeLogs(List<TradeLog> logs) async {
    Set updateLater = Set();

    return await Db().transact((txn) async {
      int i = 0;
      for (var log in logs) {
        if (++i % 10 == 0) {
          dev.log("Processed " + i.toString() + " logs");
        }
        try {
          await txn.insert(Db.tblTradeLog, log.toDbTuple());
          updateLater.add(log.id);
          await txn.insert(Db.tblTracked, {
            Db.colCode: log.code,
            Db.colExch: log.exchange,
            Db.colPinned: 0,
          });
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

  static Future<String> getTradesCSV() async {
    List<Map> tuples = await Db().getRawQuery(""
        "SELECT ${Db.colDate}, ${Db.colBSECode}, ${Db.colNSECode}, "
        "${Db.colExch}, ${Db.colBought}, T.${Db.colQty} AS ${Db.colQty}, "
        "${Db.colRate} "
        "FROM ${Db.tblTradeLog} T "
        "LEFT JOIN ${Db.tblPortfolio} P "
        "ON T.${Db.colCode} = P.${Db.colBSECode} "
        "WHERE "
        "T.${Db.colExch} = 'BSE' "
        "UNION "
        "SELECT ${Db.colDate}, ${Db.colBSECode}, ${Db.colNSECode}, "
        "${Db.colExch}, ${Db.colBought}, T.${Db.colQty} AS ${Db.colQty}, "
        "${Db.colRate} "
        "FROM ${Db.tblTradeLog} T "
        "LEFT JOIN ${Db.tblPortfolio} P "
        "ON T.${Db.colCode} = P.${Db.colNSECode} "
        "WHERE "
        "T.${Db.colExch} = 'NSE' "
        "ORDER BY ${Db.colDate} ASC");

    List<List> trades = [
      [
        "Date",
        "BSE Code",
        "NSE Code",
        "Exchange",
        "BUY/SELL",
        "Quantity",
        "Rate"
      ]
    ];

    tuples.forEach((element) {
      trades.add([
        element[Db.colDate],
        element[Db.colBSECode],
        element[Db.colNSECode],
        element[Db.colExch],
        (element[Db.colBought] == 1) ? "BUY" : "SELL",
        element[Db.colQty],
        element[Db.colRate],
      ]);
    });

    return const ListToCsvConverter().convert(trades, delimitAllFields: true);
  }

  static Future<List<TradeLog>> getStockLogs(int stockId) async {
    List<Map<String, dynamic>> tuples = await Db().getOrderedQuery(
        Db.tblTradeLog,
        '${Db.colStockID} = ?',
        [stockId],
        '${Db.colDate} DESC, ${Db.colCode} ASC');

    List<TradeLog> logs = [];
    tuples.forEach((row) => logs.add(TradeLog.fromDbTuple(row)));
    return logs;
  }

  static Future<List<Stock>?> getPinnedStocks() async {
    try {
      List<Map<String, dynamic>> tuples = await Db().getRawQuery("SELECT * "
          "FROM ${Db.tblTracked} T "
          "LEFT JOIN ${Db.tblPortfolio} P "
          "ON T.${Db.colCode} = P.${Db.colBSECode} "
          "WHERE "
          "T.${Db.colExch} = 'BSE' "
          "AND ${Db.colPinned} = 1 "
          "UNION "
          "SELECT * "
          "FROM ${Db.tblTracked} T "
          "LEFT JOIN ${Db.tblPortfolio} P "
          "ON T.${Db.colCode} = P.${Db.colNSECode} "
          "WHERE "
          "T.${Db.colExch} = 'NSE' "
          "AND ${Db.colPinned} = 1 "
          "ORDER BY ${Db.colName} ASC, ${Db.colCode} ASC");

      List<Stock> stocks = [];
      tuples.forEach((row) => stocks.add(Stock.fromDbTuple(row)));
      return stocks;
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  static Future<List<Stock>?> getUnpinnedStocks() async {
    try {
      List<Map<String, dynamic>> tuples = await Db().getRawQuery("SELECT * "
          "FROM ${Db.tblTracked} T "
          "LEFT JOIN ${Db.tblPortfolio} P "
          "ON T.${Db.colCode} = P.${Db.colBSECode} "
          "WHERE "
          "T.${Db.colExch} = 'BSE' "
          "AND ${Db.colPinned} = 0 "
          "UNION "
          "SELECT * "
          "FROM ${Db.tblTracked} T "
          "LEFT JOIN ${Db.tblPortfolio} P "
          "ON T.${Db.colCode} = P.${Db.colNSECode} "
          "WHERE "
          "T.${Db.colExch} = 'NSE' "
          "AND ${Db.colPinned} = 0 "
          "ORDER BY ${Db.colName} ASC, ${Db.colCode} ASC");

      List<Stock> stocks = [];
      tuples.forEach((row) => stocks.add(Stock.fromDbTuple(row)));
      return stocks;
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  static Future<bool> updatePinned(
      String code, String exchange, bool pinned) async {
    return await Db().updateConditionally(
      Db.tblTracked,
      {'${Db.colPinned}': pinned ? 1 : 0},
      '${Db.colCode} = ? and ${Db.colExch} = ?',
      [code, exchange],
    );
  }

  static Future<bool> deleteTracked(String code, String exchange) async {
    return await Db().deleteQuery(
      Db.tblTracked,
      '${Db.colCode} = ? and ${Db.colExch} = ?',
      [code, exchange],
    );
  }

  static Future<bool> addTracked(
      String code, String exchange, String? name, bool pinned) async {
    return await Db().insert(Db.tblTracked, {
      Db.colCode: code,
      Db.colExch: exchange,
      Db.colPinned: pinned ? 1 : 0,
      Db.colName: name,
    });
  }

  static Future<Object?> updateCode(
      String oldCode, String exch, String newCode) async {
    String codeCol = "";
    switch (exch) {
      case "BSE":
        codeCol = Db.colBSECode;
        break;
      case "NSE":
        codeCol = Db.colNSECode;
        break;
    }

    return await Db().transact((txn) async {
      await txn.update(Db.tblTracked, {Db.colCode: newCode},
          where: '${Db.colCode} = ? and ${Db.colExch} = ?',
          whereArgs: [oldCode, exch]);
      List<Map> tuples = await txn
          .query(Db.tblPortfolio, where: '$codeCol = ?', whereArgs: [newCode]);
      if (tuples.length == 0) {
        await txn.update(Db.tblPortfolio, {codeCol: newCode},
            where: '$codeCol = ?', whereArgs: [oldCode]);
        tuples = await txn.query(Db.tblPortfolio,
            where: '$codeCol = ?', whereArgs: [newCode]);
      }
      await txn.update(Db.tblTradeLog,
          {Db.colStockID: tuples.first[Db.colRowID], Db.colCode: newCode},
          where: '${Db.colCode} = ? and ${Db.colExch} = ?',
          whereArgs: [oldCode, exch]);
      return;
    }).then((value) async {
      List<Map> tuples =
          await Db().getQuery(Db.tblPortfolio, '$codeCol = ?', [newCode]);
      updatePortfolioFigures(tuples.first[Db.colRowID]);
      return value;
    });
  }

  static void deleteDbThenInit() {
    Db().deleteDbThenInit();
  }
}
