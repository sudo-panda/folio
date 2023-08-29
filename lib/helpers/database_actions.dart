import 'dart:developer' as dev;
import 'dart:io';

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
import 'package:excel/excel.dart';

import '../models/trade/parsed_file_logs.dart';

class DatabaseActions {
  static void dummyOnUpdate({int? current, String? message, int? total}) {}

  static Future<String> getDbPath() async => await Db().getDbPath();

  static Future<List<TradeLog>> getAllTrades() async {
    List<Map<String, dynamic>> tradeLogs = await Db()
        .getOrdered(Db.tblTradeLog, '${Db.colDate} DESC, ${Db.colCode} ASC');

    List<TradeLog> trades = [];
    tradeLogs.forEach((row) => trades.add(TradeLog.fromDbTuple(row)));
    return trades;
  }

  static Future<List<Portfolio>> getAllPortfolioLogs() async {
    List<Map<String, dynamic>> portfolioLogs = await Db().getRawQuery(""
        "SELECT "
        "P.${Db.colRowID} AS ${Db.colRowID}, "
        "P.${Db.colStockID} AS ${Db.colStockID}, "
        "S.${Db.colName} AS ${Db.colName}, "
        "S.${Db.colNSECode} AS ${Db.colNSECode}, "
        "S.${Db.colBSECode} AS ${Db.colBSECode}, "
        "${Db.colGrossQty}, ${Db.colAvgRate}, ${Db.colMSR}, ${Db.colESR} "
        ""
        "FROM ${Db.tblPortfolio} P "
        "LEFT JOIN ${Db.tblScrips} S "
        "ON P.${Db.colStockID} = S.${Db.colRowID} ");

    List<Portfolio> portfolio = [];
    portfolioLogs.forEach((row) => portfolio.add(Portfolio.fromDbTuple(row)));
    return portfolio;
  }

  static Future<DateTime?> getRecentDate() async {
    List<Map<String, dynamic>> tradeLogs = await Db().getLimitedOrdered(
      Db.tblTradeLog,
      1,
      '${Db.colDate} DESC',
    );

    return tradeLogs.isEmpty
        ? null
        : TradeLog.fromDbTuple(tradeLogs.first).date;
  }

  static Future<bool> setTradeLog(
    String code,
    String exchange,
    String date,
    bool bought,
    int qty,
    double rate,
  ) async {
    String codeCol = "";
    if (exchange == "BSE") {
      codeCol = Db.colBSECode;
    } else if (exchange == "NSE") {
      codeCol = Db.colNSECode;
    }
    var scrips = await Db().getQuery(Db.tblScrips, "$codeCol = ?", [code]);

    if (scrips.length > 1) {
      return false;
    } else if (scrips.length == 0) {
      bool res = await Db().insert(Db.tblScrips, {codeCol: code});
      if (!res) return res;
      scrips = await Db().getQuery(Db.tblScrips, "$codeCol = ?", [code]);
    }

    if (!(await Db().insert(
      Db.tblTradeLog,
      {
        Db.colStockID: scrips.first[Db.colRowID],
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

    if (!(await updatePortfolioFigures(scrips.first[Db.colRowID]))) {
      return false;
    }

    var trackedStocks = await Db().getQuery(Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?', [code, exchange]);

    if (trackedStocks.length == 0) {
      return await Db().insert(Db.tblTracked, {
        Db.colStockID: scrips.first[Db.colRowID],
        Db.colCode: code,
        Db.colExch: exchange,
        Db.colPinned: 0,
      });
    } else {
      return true;
    }
  }

  static Future<bool> updatePortfolioFigures(int stockID) async {
    try {
      await Db().insert(Db.tblPortfolio, {Db.colStockID: stockID});
    } on DatabaseException catch (e) {
      if (!e.isUniqueConstraintError()) {
        throw e;
      }
    }

    var buyLogs = await DatabaseActions.getBuyTrades(stockID);
    var sellLogs = await DatabaseActions.getSellTrades(stockID);

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
          // FIXME: throw exception
          await Db().updateConditionally(
            Db.tblPortfolio,
            {
              Db.colGrossQty: qty,
              Db.colMSR: msr,
              Db.colESR: esr,
            },
            '${Db.colStockID} = ?',
            [stockID],
          );
          var scrips = await Db().getQuery(
            Db.tblScrips,
            '${Db.colRowID} = ?',
            [stockID],
          );
          await Db().deleteQuery(
            Db.tblTracked,
            '${Db.colCode} = ? and ${Db.colExch} = ?',
            [scrips.first[Db.colBSECode], "BSE"],
          );

          await Db().deleteQuery(
            Db.tblTracked,
            '${Db.colCode} = ? and ${Db.colExch} = ?',
            [scrips.first[Db.colNSECode], "NSE"],
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
      var scrips = await Db().getQuery(
        Db.tblScrips,
        '${Db.colRowID} = ?',
        [stockID],
      );
      await Db().deleteQuery(
        Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?',
        [scrips.first[Db.colBSECode], "BSE"],
      );

      await Db().deleteQuery(
        Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?',
        [scrips.first[Db.colNSECode], "NSE"],
      );
    }

    bool res = await Db().updateConditionally(
      Db.tblPortfolio,
      {
        Db.colGrossQty: qty,
        Db.colMSR: msr,
        Db.colESR: esr,
      },
      '${Db.colStockID} = ?',
      [stockID],
    );

    return res;
  }

  static Future<List<TradeLog>> getBuyTrades(int stockID) async {
    List<Map<String, dynamic>> buyTradeLogs = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colStockID} = ?',
      [1, stockID],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> buyTrades = [];
    buyTradeLogs.forEach((element) {
      buyTrades.add(TradeLog.fromDbTuple(element));
    });
    return buyTrades;
  }

  static Future<List<TradeLog>> getSellTrades(int stockID) async {
    List<Map<String, dynamic>> sellTradeLogs = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colStockID} = ?',
      [0, stockID],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> sellTrades = [];
    sellTradeLogs.forEach((element) {
      sellTrades.add(TradeLog.fromDbTuple(element));
    });
    return sellTrades;
  }

  static Future<int> setCodesNGetStockID(String? bseCode, String? nseCode,
      [String? name]) async {
    List<Map> scrips;

    if (bseCode != null && nseCode != null) {
      scrips = await Db().getQuery(Db.tblScrips,
          '${Db.colBSECode} = ? or ${Db.colNSECode} = ?', [bseCode, nseCode]);
    } else if (bseCode != null) {
      scrips =
          await Db().getQuery(Db.tblScrips, '${Db.colBSECode} = ?', [bseCode]);
    } else if (nseCode != null) {
      scrips =
          await Db().getQuery(Db.tblScrips, '${Db.colNSECode} = ?', [nseCode]);
    } else {
      throw ArgumentError("Both BSE and NSE codes cannot be null!");
    }

    if (scrips.length == 0) {
      await Db().insert(
        Db.tblScrips,
        {
          Db.colBSECode: bseCode,
          Db.colNSECode: nseCode,
          Db.colName: name,
        },
      );
    } else {
      if (bseCode == null) {
        bseCode = scrips[0][Db.colBSECode];
      }
      if (nseCode == null) {
        nseCode = scrips[0][Db.colNSECode];
      }

      if (scrips.length == 1) {
        await Db().updateConditionally(
          Db.tblScrips,
          name == null
              ? {
                  Db.colBSECode: bseCode,
                  Db.colNSECode: nseCode,
                }
              : {
                  Db.colBSECode: bseCode,
                  Db.colNSECode: nseCode,
                  Db.colName: name,
                },
          '${Db.colBSECode} = ? or ${Db.colNSECode} = ?',
          [bseCode, nseCode],
        );
        return scrips.first[Db.colRowID];
      } else {
        await Db().transact((txn) async {
          await txn.delete(
            Db.tblScrips,
            where: '${Db.colBSECode} = ? or ${Db.colNSECode} = ?',
            whereArgs: [bseCode, nseCode],
          );
          await txn.insert(
            Db.tblScrips,
            {
              Db.colBSECode: bseCode,
              Db.colNSECode: nseCode,
              Db.colName: name,
            },
          );
        });
      }
    }

    var updatedScrips = await Db().getQuery(Db.tblScrips,
        '${Db.colBSECode} = ? or ${Db.colNSECode} = ?', [bseCode, nseCode]);
    return updatedScrips.first[Db.colRowID];
  }

  static Future<bool> linkCodes(Map<String, String> codes) async {
    int id = await setCodesNGetStockID(codes["BSE"], codes["NSE"]);

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

  static Future<ParsedFileLogs> parseSBIFile(String filepath,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    onUpdate(message: "Parsing SBI File");

    var bytes = File(filepath).readAsBytesSync();
    var excelFile = Excel.decodeBytes(bytes);

    if (excelFile.sheets.isEmpty) {
      throw ArgumentError("Excel file has no sheets");
    }
    Sheet excelSheet = excelFile.sheets.values.first;
    var parsedLogs = ParsedFileLogs();

    int dateColID = 0,
        exchangeColID = 3,
        nameColID = 8,
        boughtColID = 9,
        qtyColID = 10,
        rateColID = 11;
    int startRow = 3;
    onUpdate(
        message: "Parsing SBI File",
        current: 0,
        total: excelSheet.maxRows - startRow);
    for (int rowIndex = startRow; rowIndex < excelSheet.maxRows; rowIndex++) {
      onUpdate(
          message: "Parsing SBI File",
          current: rowIndex - startRow + 1,
          total: excelSheet.maxRows - startRow);
      var row = excelSheet.row(rowIndex);
      DateTime? date;
      var dateString = row[dateColID]?.value.toString();
      if (dateString != null) {
        dateString = dateString.substring(0, dateString.lastIndexOf("T"));
        int year = int.parse(dateString.substring(0, dateString.indexOf('-')));
        int month = int.parse(dateString.substring(
            dateString.indexOf('-') + 1, dateString.lastIndexOf('-')));
        int day = int.parse(dateString.substring(dateString.lastIndexOf('-')));
        date = DateTime.utc(year, month, day);
      }
      String? exchange = row[exchangeColID]?.value.toString().trim();
      String? name = row[nameColID]?.value.toString();
      bool? bought = row[boughtColID]?.value.toString() == "B";
      int? qty = row[qtyColID] == null
          ? null
          : int.parse(row[qtyColID]!.value.toString());
      double? rate = row[rateColID] == null
          ? null
          : double.parse(row[rateColID]!.value.toString());

      parsedLogs.invalidLogs
          .add(FileLog(date, name, null, null, exchange, bought, qty, rate));
    }

    return parsedLogs;
  }

  static Future<ParsedFileLogs> parseOldSBIFile(String file,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    onUpdate(message: "Parsing SBI File (old format)");
    Document parsedHTML = html.parse(file);
    List<String> headers = [];

    // dev.log(parsedHTML.outerHtml);

    Element? table = parsedHTML.querySelector("#grdViewTradeDetail");

    if (table == null) {
      table = parsedHTML.querySelector("#grdViewTradeDetail_old");
    }

    if (table == null) throw FormatException("File format is not correct");

    for (var cell
        in table.querySelectorAll("tr").first.querySelectorAll("th")) {
      headers.add(cell.innerHtml);
    }

    var parsedLogs = ParsedFileLogs();

    int skipRows = 1;
    int rowNum = 0;

    onUpdate(
        message: "Parsing SBI File (old format)",
        current: rowNum,
        total: table.querySelectorAll("tr").length - skipRows);

    for (var row in table.querySelectorAll("tr").skip(skipRows)) {
      onUpdate(
          message: "Parsing SBI File (old format)",
          current: ++rowNum,
          total: table.querySelectorAll("tr").length - skipRows);

      DateTime? date;
      String? exchange, scripCode, scripName, code;
      int buyQty = 0, sellQty = 0;
      double? buyRate, sellRate;

      int colNum = 0;
      for (var cell in row.querySelectorAll("td")) {
        switch (headers[colNum]) {
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
                .documentElement!
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
        colNum++;
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

      if (buyQty > 0) {
        var log = FileLog(
            date, null, scripCode, scripName, exchange, true, buyQty, buyRate);
        if (date == null || code == null || exchange == null || buyRate == null)
          parsedLogs.invalidLogs.add(log);
        else
          parsedLogs.validLogs.add(log);
      }

      if (sellQty > 0) {
        var log = FileLog(date, null, scripCode, scripName, exchange, false,
            sellQty, sellRate);
        if (date == null ||
            code == null ||
            exchange == null ||
            sellRate == null)
          parsedLogs.invalidLogs.add(log);
        else
          parsedLogs.validLogs.add(log);
      }
    }

    onUpdate(message: "Parsed SBI File (old format)");

    return parsedLogs;
  }

  static Future<ParsedFileLogs> parseCSVFile(String file,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    var detector = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    List<List<dynamic>> trades =
        const CsvToListConverter().convert(file, csvSettingsDetector: detector);

    var parsedLogs = ParsedFileLogs();

    for (var row in trades.skip(1)) {
      DateTime? date;
      String? exchange, name, code, bseCode, nseCode;
      int? qty;
      double? rate;
      bool? bought;

      int i = 0;
      for (var element in row) {
        switch (trades.first[i]) {
          case "Date":
            if (element == "null") break;

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
            if (element == "null") break;
            exchange = element;
            break;
          case "Name":
            if (element == "null") break;
            name = element;
            break;
          case "BSE Code":
            if (element == "null") break;
            bseCode = element.toString();
            break;
          case "NSE Code":
            if (element == "null") break;
            nseCode = element.toString();
            break;
          case "Quantity":
            if (element == "null") break;
            qty = int.parse(element.toString());
            break;
          case "Rate":
            if (element == "null") break;
            rate = double.parse(element.toString());
            break;
          case "BUY/SELL":
            if (element == "null") break;
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

      var log =
          FileLog(date, name, bseCode, nseCode, exchange, bought, qty, rate);
      if (date == null ||
          code == null ||
          exchange == null ||
          bought == null ||
          qty == null ||
          rate == null)
        parsedLogs.invalidLogs.add(log);
      else
        parsedLogs.validLogs.add(log);
    }

    return parsedLogs;
  }

  static Future<Object?> addTradeLogs(List<TradeLog> logs,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    Set updateLater = Set();

    return await Db().transact((txn) async {
      int i = 0;
      onUpdate(message: "Adding trade logs...", current: i, total: logs.length);

      for (var log in logs) {
        if (++i % 10 == 0) {
          dev.log("Processed " + i.toString() + " trade logs");
        }
        onUpdate(
            message: "Adding trade logs...", current: i, total: logs.length);

        try {
          await txn.insert(Db.tblTradeLog, log.toDbTuple());
          updateLater.add(log.id);
        } on DatabaseException catch (e) {
          onUpdate(
              message:
                  "Unknown Error Occurred ... \n${e.toString()}\n${log.toString()}",
              current: i,
              total: logs.length);
          throw e;
        }

        try {
          await txn.insert(Db.tblTracked, {
            Db.colStockID: log.id,
            Db.colCode: log.code,
            Db.colExch: log.exchange,
            Db.colPinned: 0,
          });
        } on DatabaseException catch (e) {
          if (e.isUniqueConstraintError()) {
            dev.log("Unique constraint error on ${log.toString()}!");
            continue;
          } else {
            onUpdate(
                message: "Unknown Error Occurred ...",
                current: i,
                total: logs.length);
            throw e;
          }
        }
      }
    }).then((value) async {
      int i = 0;
      onUpdate(
          message: "Updating Portfolio ...",
          current: i,
          total: updateLater.length);
      for (var id in updateLater) {
        onUpdate(
            message: "Updating Portfolio ...",
            current: ++i,
            total: updateLater.length);
        await updatePortfolioFigures(id);
      }
      return value;
    });
  }

  static Future<List<TradeLog>> addFileLogs(List<FileLog> logs,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    // Creating Trade Logs...
    List<TradeLog> trades = [];
    int i = 0;
    onUpdate(
        message: "Creating trade logs ...", current: i, total: logs.length);
    for (var fileLog in logs) {
      if (++i % 10 == 0) {
        dev.log("Created " + i.toString() + " trade logs");
      }

      onUpdate(
          message: "Creating trade logs ...", current: i, total: logs.length);

      if (fileLog.date == null ||
          fileLog.code == null ||
          fileLog.exchange == null ||
          fileLog.bought == null ||
          fileLog.qty == null ||
          fileLog.rate == null) {
        onUpdate(
            message: "Invalid logs found!", current: i, total: logs.length);
        throw Exception("Invalid logs found!");
      }

      try {
        int id = await DatabaseActions.setCodesNGetStockID(
            fileLog.bseCode, fileLog.nseCode, fileLog.name);

        trades.add(TradeLog(fileLog.date!, id, fileLog.code!, fileLog.exchange!,
            fileLog.bought!, fileLog.qty!, fileLog.rate!));
      } catch (e) {
        onUpdate(
            message: "Unknown Error Occurred!", current: i, total: logs.length);
        throw e;
      }

      i++;
    }

    await addTradeLogs(trades, onUpdate: onUpdate);

    return trades;
  }

  static Future<String> getTradesCSV() async {
    List<Map> tradeLogs = await Db().getRawQuery(""
        "SELECT "
        "S.${Db.colName} AS ${Db.colName}, "
        "S.${Db.colBSECode} AS ${Db.colBSECode}, "
        "S.${Db.colNSECode} AS ${Db.colNSECode}, "
        "${Db.colDate}, ${Db.colExch}, ${Db.colBought}, "
        "${Db.colQty}, ${Db.colRate} "
        "FROM ${Db.tblTradeLog} L "
        "LEFT JOIN ${Db.tblScrips} S "
        "ON L.${Db.colStockID} = S.${Db.colRowID} "
        "ORDER BY ${Db.colDate} ASC");

    List<List> trades = [
      [
        "Date",
        "Name",
        "BSE Code",
        "NSE Code",
        "Exchange",
        "BUY/SELL",
        "Quantity",
        "Rate"
      ]
    ];

    tradeLogs.forEach((element) {
      trades.add([
        element[Db.colDate],
        element[Db.colName],
        element[Db.colBSECode],
        element[Db.colNSECode],
        element[Db.colExch],
        (element[Db.colBought] == 1) ? "BUY" : "SELL",
        element[Db.colQty],
        element[Db.colRate],
      ]);
    });

    var converter = const ListToCsvConverter();
    return converter.convert(trades, delimitAllFields: true);
  }

  static Future<List<TradeLog>> getStockTrades(int stockId) async {
    List<Map<String, dynamic>> tradeLogs = await Db().getOrderedQuery(
        Db.tblTradeLog,
        '${Db.colStockID} = ?',
        [stockId],
        '${Db.colDate} DESC');

    List<TradeLog> trades = [];
    tradeLogs.forEach((row) => trades.add(TradeLog.fromDbTuple(row)));
    return trades;
  }

  static Future<List<Stock>?> getPinnedStocks() async {
    try {
      List<Map<String, dynamic>> trackedPinned =
          await Db().getRawQuery("SELECT * "
              "FROM ${Db.tblTracked} T "
              "LEFT JOIN ${Db.tblScrips} S "
              "ON T.${Db.colStockID} = S.${Db.colRowID} "
              "LEFT JOIN ${Db.tblPortfolio} P "
              "ON T.${Db.colStockID} = P.${Db.colStockID} "
              "WHERE "
              "${Db.colPinned} = 1 "
              "ORDER BY ${Db.colName} ASC");

      List<Stock> stocks = [];
      trackedPinned.forEach((row) => stocks.add(Stock.fromDbTuple(row)));
      return stocks;
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  static Future<List<Stock>?> getUnpinnedStocks() async {
    try {
      List<Map<String, dynamic>> trackedUnpinned =
          await Db().getRawQuery("SELECT * "
              "FROM ${Db.tblTracked} T "
              "LEFT JOIN ${Db.tblScrips} S "
              "ON T.${Db.colStockID} = S.${Db.colRowID} "
              "LEFT JOIN ${Db.tblPortfolio} P "
              "ON T.${Db.colStockID} = P.${Db.colStockID} "
              "WHERE "
              "${Db.colPinned} = 0 "
              "ORDER BY ${Db.colName} ASC");

      List<Stock> stocks = [];
      trackedUnpinned.forEach((row) => stocks.add(Stock.fromDbTuple(row)));
      return stocks;
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  static Future<bool> setScripName(
      String exchange, String? name, String code) async {
    String codeCol = "";
    if (exchange == "BSE") {
      codeCol = Db.colBSECode;
    } else if (exchange == "NSE") {
      codeCol = Db.colNSECode;
    }

    return await Db().updateConditionally(Db.tblScrips,
        {Db.colName: name?.toUpperCase()}, '$codeCol = ?', [code]);
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
      String code, String exchange, bool pinned) async {
    String codeCol = "";
    switch (exchange) {
      case "BSE":
        codeCol = Db.colBSECode;
        break;
      case "NSE":
        codeCol = Db.colNSECode;
        break;
    }

    return await Db().transact((txn) async {
      // Check if Scrips has the newCode already
      List<Map> scrips = await txn
          .query(Db.tblScrips, where: '$codeCol = ?', whereArgs: [code]);

      // If not present then update the oldCode with newCode
      if (scrips.length == 0) {
        await txn.insert(Db.tblScrips, {codeCol: code});
        scrips = await txn
            .query(Db.tblScrips, where: '$codeCol = ?', whereArgs: [code]);
      }

      await txn.insert(Db.tblTracked, {
        Db.colStockID: scrips.first[Db.colRowID],
        Db.colCode: code,
        Db.colExch: exchange,
        Db.colPinned: pinned ? 1 : 0,
      });
    }).then((value) => true);
  }

  static Future<Object?> updateCode(
      String oldCode, String exchange, String newCode) async {
    String codeCol = "";
    switch (exchange) {
      case "BSE":
        codeCol = Db.colBSECode;
        break;
      case "NSE":
        codeCol = Db.colNSECode;
        break;
    }

    return await Db().transact((txn) async {
      // Check if Scrips has the newCode already
      List<Map> scrips = await txn
          .query(Db.tblScrips, where: '$codeCol = ?', whereArgs: [newCode]);

      // If not present then update the oldCode with newCode
      if (scrips.length == 0) {
        await txn.update(Db.tblScrips, {codeCol: newCode},
            where: '$codeCol = ?', whereArgs: [oldCode]);
        scrips = await txn
            .query(Db.tblScrips, where: '$codeCol = ?', whereArgs: [newCode]);
      }

      // Update Tracked table replacing oldCode with newCode
      await txn.update(Db.tblTracked,
          {Db.colStockID: scrips.first[Db.colRowID], Db.colCode: newCode},
          where: '${Db.colCode} = ? and ${Db.colExch} = ?',
          whereArgs: [oldCode, exchange]);
      await txn.update(Db.tblTradeLog,
          {Db.colStockID: scrips.first[Db.colRowID], Db.colCode: newCode},
          where: '${Db.colCode} = ? and ${Db.colExch} = ?',
          whereArgs: [oldCode, exchange]);
      return;
    }).then((value) async {
      List<Map> scrips =
          await Db().getQuery(Db.tblScrips, '$codeCol = ?', [newCode]);
      updatePortfolioFigures(scrips.first[Db.colRowID]);
      return value;
    });
  }

  static void deleteDbThenInit() {
    Db().deleteDbThenInit();
  }
}
