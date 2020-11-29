import 'dart:developer';

import 'package:folio/helpers/database.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/settings/data/database_actions.dart' as imp;

class DatabaseActions {
  static Future<List<TradeLog>> getStockLogs(int stockId) async {
    List<Map> tuples = await Db().getOrderedQuery(
        Db.tblTradeLog,
        '${Db.colStockID} = ?',
        [stockId],
        '${Db.colDate} DESC, ${Db.colCode} ASC');

    List<TradeLog> logs = [];
    tuples.forEach((row) => logs.add(TradeLog.fromDbTuple(row)));
    return logs;
  }

  static Future<List<Stock>> getPinnedStocks() async {
    try {
      List<Map> tuples = await Db().getRawQuery("SELECT * "
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
      log(e.toString());
      return null;
    }
  }

  static Future<List<Stock>> getUnpinnedStocks() async {
    try {
      List<Map> tuples = await Db().getRawQuery("SELECT * "
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
      log(e.toString());
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
      String code, String exchange, String name, bool pinned) async {
    return await Db().insert(Db.tblTracked, {
      Db.colCode: code,
      Db.colExch: exchange,
      Db.colPinned: pinned ? 1 : 0,
      Db.colName: name,
    });
  }

  static Future<T> updateCode<T>(
      String oldCode, String exch, String newCode) async {
    String codeCol;
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
      imp.DatabaseActions.updatePortfolioFigures(tuples.first[Db.colRowID]);
      return value;
    });
  }
}
