import 'dart:developer' as dev;
import 'dart:io';

import 'package:csv/csv_settings_autodetection.dart';
import 'package:folio/models/database/scrip.dart';
import 'package:folio/services/database/database.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/models/database/portfolio.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/state/globals.dart';
import 'package:folio/views/settings/data/import_scrips_list/parsed_scrips.dart';

import 'package:html/parser.dart' as html;
import 'package:sqflite/sqflite.dart';
import 'package:html/dom.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../models/trade/parsed_file_logs.dart';

class DataException implements Exception {
  final String message;

  DataException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class DatabaseActions {
  static const String delimiter = "; ";
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

  static Future<bool> addTradeLog(
    String code,
    String exchange,
    String date,
    bool bought,
    int qty,
    double rate,
  ) async {
    String codeCol = getCodeCol(exchange);
    var scrips = await Db().getQuery(Db.tblScrips, "$codeCol = ?", [code]);

    if (scrips.length > 1) {
      throw DataException(
          "Multiple stocks with same code present in securities list. "
          "Please delete duplicates!");
    }

    if (scrips.length == 0) {
      throw DataException("Stock not present in securities list!");
    }

    bool isTradeInserted = await Db().insert(
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
    );
    
    if (!isTradeInserted) {
      throw DataException("Couldn't add trade to logs!");
    }

    await updatePortfolioFigures(scrips.first[Db.colRowID]);

    var trackedStocks = await Db().getQuery(Db.tblTracked,
        '${Db.colCode} = ? and ${Db.colExch} = ?', [code, exchange]);

    if (trackedStocks.length == 0) {
      return await Db().insert(Db.tblTracked, {
        Db.colStockID: scrips.first[Db.colRowID],
        Db.colCode: code,
        Db.colExch: exchange,
        Db.colPinned: 0,
      });
    }
    
    return true;
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

  static Future<List<Map<String, dynamic>>> getScripsFromOldCode(
      String exchange, String code) async {
    var res = await Db().getQuery(
        Db.tblScrips, "${getOldCodesCol(exchange)} LIKE ?", ["%$code%"]);
    return res;
  }

  static Future<List<Map<String, dynamic>>> getScripsFromCode(
      String exchange, String code) async {
    var res = await Db()
        .getQuery(Db.tblScrips, "${getCodeCol(exchange)} = ?", [code]);
    return res;
  }

  static Future<List<Map<String, dynamic>>> getScripsFromName(
      String name) async {
    var res = await Db().getQuery(
        Db.tblScrips, "${Db.colName} LIKE ?", ["${getNormalizedName(name)}%"]);
    return res;
  }

  static Future<bool> isOldCodePresent(String exchange, String code) async {
    return (await getScripsFromOldCode(exchange, code)).length != 0;
  }

  static Future<bool> isCodePresent(String exchange, String code) async {
    var tuples = await getScripsFromCode(exchange, code);
    return tuples.length != 0;
  }

  static Future<bool> isScripNamePresent(String name) async {
    var tuples = await getScripsFromName(name);
    return tuples.length != 0;
  }

  static Future<List<Scrip>?> getAllScrips() async {
    var scripsTuple = await Db().getOrdered(Db.tblScrips, "${Db.colName} ASC");
    List<Scrip> scripsList = [];
    scripsTuple.forEach((row) => scripsList.add(Scrip.fromDbTuple(row)));
    return scripsList;
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
      String? name = getNormalizedName(row[nameColID]?.value.toString());
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
            try {
              date = DateTime.utc(
                  int.parse(cell.innerHtml
                      .substring(cell.innerHtml.lastIndexOf('/') + 1)),
                  int.parse(cell.innerHtml.substring(
                      cell.innerHtml.indexOf('/') + 1,
                      cell.innerHtml.lastIndexOf('/'))),
                  int.parse(cell.innerHtml
                      .substring(0, cell.innerHtml.indexOf('/'))));
            } catch (e) {}
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
            try {
              buyQty = int.parse(cell.innerHtml.trim());
            } catch (e) {}
            break;
          case "Sold Qty":
            try {
              sellQty = int.parse(cell.innerHtml.trim());
            } catch (e) {}
            break;
          case "Buy Rate":
            try {
              buyRate = double.parse(cell.innerHtml.trim());
            } catch (e) {}
            break;
          case "Sold Rate":
            try {
              sellRate = double.parse(cell.innerHtml.trim());
            } catch (e) {}
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

      int colNum = 0;
      for (var element in row) {
        switch (trades.first[colNum]) {
          case "Date":
            if (element == "null") break;

            try {
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
            } catch (e) {}
            break;
          case "Exchange":
            if (element == "null") break;
            exchange = element;
            break;
          case "Name":
            if (element == "null") break;
            name = getNormalizedName(element);
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
            try {
              qty = int.parse(element.toString());
            } catch (e) {}
            break;
          case "Rate":
            if (element == "null") break;
            try {
              rate = double.parse(element.toString());
            } catch (e) {}
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
        colNum++;
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
        throw DataException("Invalid logs found!");
      }

      if (fileLog.stockID == null) {
        var res = await DatabaseActions.getScripsFromCode(
            fileLog.exchange!, fileLog.code!);

        if (res.length == 0)
          throw DataException(
              "Stock of ${fileLog.name} not present in securities list");

        fileLog.stockID = Scrip.fromDbTuple(res.first).stockID;
      }

      trades.add(TradeLog(fileLog.date!, fileLog.stockID!, fileLog.code!,
          fileLog.exchange!, fileLog.bought!, fileLog.qty!, fileLog.rate!));

      i++;
    }

    await addTradeLogs(trades, onUpdate: onUpdate);

    return trades;
  }

  static Future<ParsedScripsList> parseCSVScripsFile(
      String exchange, String file,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    onUpdate(message: "Parsing Scrips File");
    var detector = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    List<List<dynamic>> scrips =
        const CsvToListConverter().convert(file, csvSettingsDetector: detector);

    Map<String, ParsedScrip> scripsMap = {};

    switch (exchange) {
      case "BSE":
        int i = 0;
        onUpdate(
            message: "Parsing BSE Scrips File",
            current: i,
            total: scrips.length - 1);
        for (var row in scrips.skip(1)) {
          onUpdate(
              message: "Parsing BSE Scrips File",
              current: ++i,
              total: scrips.length - 1);

          String code = row[0].toString();
          String name = getNormalizedName(row[3].toString())!;
          bool isActive = (row[4].toString() == "Active");
          if (scripsMap[name] == null) {
            if (isActive)
              scripsMap[name] = ParsedScrip(name, code);
            else
              scripsMap[name] = ParsedScrip(name, null, [code]);
          } else {
            if (isActive) {
              if (scripsMap[name]!.newCode == null)
                scripsMap[name]!.newCode = code;
              else {
                scripsMap[name]!.oldCodes.add(code);
                // onUpdate(
                //     message: "Two codes ${scripsMap[name]!.newCode} & $code for"
                //         " the same stock $name found!",
                //     current: i,
                //     total: null);
                // throw DataException("Two codes ${scripsMap[name]!.newCode} & $code for"
                //     " the same stock $name found!");
              }
            } else {
              scripsMap[name]!.oldCodes.add(code);
            }
          }
        }

        break;
      case "NSE":
        int i = 0;
        onUpdate(
            message: "Parsing NSE Scrips File",
            current: i,
            total: scrips.length - 1);
        for (var row in scrips.skip(1)) {
          onUpdate(
              message: "Parsing NSE Scrips File",
              current: ++i,
              total: scrips.length - 1);

          String code = row[0].toString();
          String name = getNormalizedName(row[1].toString())!;
          scripsMap[name] = ParsedScrip(name, code);
        }

        break;
    }

    ParsedScripsList scripsList = ParsedScripsList(exchange);
    int i = 0, total = scripsMap.values.length;
    onUpdate(message: "Checking Parsed Scrips", current: i, total: total);

    for (var scrip in scripsMap.values) {
      onUpdate(message: "Checking Parsed Scrips", current: ++i, total: total);

      ParsedScrip checkedScrip = ParsedScrip.from(scrip);

      for (var oldCode in scrip.oldCodes) {
        if (await isOldCodePresent(exchange, oldCode) ||
            await isCodePresent(exchange, oldCode)) {
          checkedScrip.oldCodes.remove(oldCode);
        }
      }

      if (checkedScrip.oldCodes.length == 0) {
        if (scrip.newCode == null ||
            await isCodePresent(exchange, scrip.newCode!)) {
          continue;
        }
      }

      if (scrip.newCode != null) {
        var newCodeScrip = await getScripsFromOldCode(exchange, scrip.newCode!);
        if (newCodeScrip.length != 0) {
          checkedScrip.newCode = newCodeScrip.first[getCodeCol(exchange)];
        }
      }

      scripsList.addNew(checkedScrip);
    }

    onUpdate(message: "Done", current: total, total: total);

    return scripsList;
  }

  static addScrips(ParsedScripsList scripsList,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    var exchange = scripsList.exchange, total = scripsList.newScrips.length;

    int i = 0;
    onUpdate(message: "Importing Scrips", current: i, total: total);

    for (var scrip in scripsList.newScrips) {
      onUpdate(message: "Importing Scrips", current: ++i, total: total);
      var scripTuple = await getScripsFromName(scrip.name);
      if (scripTuple.length == 0) {
        Scrip newScrip = Scrip(getNormalizedName(scrip.name)!);
        newScrip.setCode(exchange, scrip.newCode);
        newScrip.setOldCodes(exchange, scrip.oldCodes);
        Db().insert(Db.tblScrips, newScrip.toDbTuple());
      } else {
        Scrip existingScrip = Scrip.fromDbTuple(scripTuple.first);
        String? existingCode = existingScrip.code(exchange);
        List<String> existingOldCodes = existingScrip.oldCodes(exchange);
        for (var oldCode in scrip.oldCodes) {
          if (!existingOldCodes.contains(oldCode)) {
            existingOldCodes.add(oldCode);
          }
        }

        if (scrip.newCode == null && existingCode != null) {
          existingOldCodes.add(existingCode);
        }

        Db().updateConditionally(
            Db.tblScrips,
            {
              getCodeCol(exchange): scrip.newCode,
              getOldCodesCol(exchange): existingOldCodes.join(delimiter)
            },
            "${Db.colName} = ?",
            [getNormalizedName(scrip.name)]);
      }
    }
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

  static Future<String> getScripCode(String name, String exchange) async {
    var scrips = await Db()
        .getQuery(Db.tblScrips, "${Db.colName} = ?", [getNormalizedName(name)]);
    return scrips.first[getCodeCol(exchange)];
  }

  static String getCodeCol(String exchange) {
    switch (exchange) {
      case "BSE":
        return Db.colBSECode;
      case "NSE":
        return Db.colNSECode;
    }

    return "";
  }

  static String getOldCodesCol(String exchange) {
    switch (exchange) {
      case "BSE":
        return Db.colOldBSECodes;
      case "NSE":
        return Db.colOldNSECodes;
    }

    return "";
  }

  static Future<bool> setScripName(
      String exchange, String name, String code) async {
    String codeCol = getCodeCol(exchange);

    return await Db().updateConditionally(Db.tblScrips,
        {Db.colName: getNormalizedName(name)}, '$codeCol = ?', [code]);
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
    String codeCol = getCodeCol(exchange);

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
    String codeCol = getCodeCol(exchange);

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

  static Future<ParsedFileLogs> resolveInvalidLogs(ParsedFileLogs logs,
      {void Function({int? current, String? message, int? total}) onUpdate =
          dummyOnUpdate}) async {
    int i = 0;
    onUpdate(
        message: "Trying to fix invalid logs",
        current: i,
        total: logs.invalidLogs.length);
    List<int> removeIndexes = [];
    for (var log in logs.invalidLogs) {
      onUpdate(
          message: "Trying to fix invalid logs",
          current: i + 1,
          total: logs.invalidLogs.length);
      // Find code if not present
      if (log.code == null && log.name != null && log.exchange != null) {
        var scripsTuple = await getScripsFromName(log.name!);
        if (scripsTuple.length != 0) {
          var scrip = Scrip.fromDbTuple(scripsTuple.first);
          log.bseCode = scrip.bseCode;
          log.nseCode = scrip.nseCode;
          log.stockID = scrip.stockID;
        }
      }

      if (log.date != null &&
          log.code != null &&
          log.exchange != null &&
          log.bought != null &&
          log.qty != null &&
          log.rate != null) {
        logs.validLogs.add(log);
        removeIndexes.add(i);
      }

      i++;
    }

    for (var index in removeIndexes.reversed) {
      logs.invalidLogs.removeAt(index);
    }

    return logs;
  }

  /// Normalize stock names to prevent string matching problems
  static String? getNormalizedName(String? name) {
    if (name == null) return null;
    name = name.toUpperCase().trim();

    // BSE List of scrips contain these unnecessary characters at the end
    if (name.endsWith("-\$")) {
      name = name.substring(0, name.length - 2);
    }

    // Shorten words to common acronyms
    name = " $name ";
    name = name
        .replaceAll(" CO.LTD. ", " CO. LTD. ")
        .replaceAll(" ENGG.LTD. ", " ENGG. LTD. ")
        .replaceAll(" ENGINEERING ", " ENGG. ")
        .replaceAll(" LIMITED ", " LTD. ")
        .replaceAll(" LTD ", " LTD. ")
        .replaceAll(" COMPANY ", " CO. ")
        .replaceAll(" ENTERPRISES ", " ENT. ")
        .replaceAll(" ENT ", " ENT. ")
        .replaceAll(" CORPORATION ", " CORP. ")
        .replaceAll(" CORP ", " CORP. ");

    return name.trim();
  }

  static void editScripName(int stockID, String name) async {
    var tuples = await getScripsFromName(name);
    if (tuples.length == 0) {
      await Db().updateConditionally(
          Db.tblScrips, {Db.colName: name}, "${Db.colRowID} = ?", [stockID]);
    } else if (tuples.first[Db.colRowID] != stockID) {
      throw DataException("Scrip name already present!");
    }
  }

  static Future<void> deleteScrip(int stockID) async {
    var portfolioLogs =
        await Db().getQuery(Db.tblPortfolio, "${Db.colStockID} = ?", [stockID]);
    if (portfolioLogs.isNotEmpty)
      throw DataException(
          "Can't delete security as it exists in your Portfolio");

    var tradeLogs =
        await Db().getQuery(Db.tblTradeLog, "${Db.colStockID} = ?", [stockID]);
    if (tradeLogs.isNotEmpty)
      throw DataException(
          "Can't delete security as it exists in your TradeLogs");

    var trackedTuple =
        await Db().getQuery(Db.tblTracked, "${Db.colStockID} = ?", [stockID]);
    if (trackedTuple.isNotEmpty)
      throw DataException(
          "Can't delete security as it exists in your Tracked list");

    await Db().deleteQuery(Db.tblScrips, "${Db.colRowID} = ?", [stockID]);
  }
}
