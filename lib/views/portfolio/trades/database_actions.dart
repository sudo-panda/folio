import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/stock.dart';
import 'package:folio/models/trades/trade_log.dart';

class DatabaseActions {
  static DatabaseHelper db = DatabaseHelper();

  static Future<List<TradeLog>> getBuyLogs(String code, String exchange) async {
    List<Map> tuples = await db.getOrderedQuery(
      DatabaseHelper.tableTradeLog,
      '${DatabaseHelper.colBought} = ? and ${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [1, code, exchange],
      '${DatabaseHelper.colDate} ASC, ${DatabaseHelper.colRate} ASC',
    );

    List<TradeLog> buyLogs = [];
    tuples.forEach((element) {
      buyLogs.add(TradeLog.fromTradeLogTuple(element));
    });
    return buyLogs;
  }

  static Future<List<TradeLog>> getSellLogs(
      String code, String exchange) async {
    List<Map> tuples = await db.getOrderedQuery(
      DatabaseHelper.tableTradeLog,
      '${DatabaseHelper.colBought} = ? and ${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [0, code, exchange],
      '${DatabaseHelper.colDate} ASC, ${DatabaseHelper.colRate} ASC',
    );

    List<TradeLog> sellLogs = [];
    tuples.forEach((element) {
      sellLogs.add(TradeLog.fromTradeLogTuple(element));
    });
    return sellLogs;
  }

  static Future<bool> updatePortfolioName(
      String code, String exchange, String name) async {
    return await db.updateConditionally(
      DatabaseHelper.tablePortfolio,
      {DatabaseHelper.colName: name},
      '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [code, exchange],
    );
  }

  static Future<bool> updatePortfolioCodeExch(String oldCode,
      String oldExchange, String newCode, String newExchange) async {
    int count = await db.getQueryCount(
      DatabaseHelper.tablePortfolio,
      '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [newCode, newExchange],
    );
    bool res;

    if (count == 0) {
      res = await db.updateConditionally(
        DatabaseHelper.tablePortfolio,
        {
          DatabaseHelper.colCode: newCode,
          DatabaseHelper.colExchange: newExchange
        },
        '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
        [oldCode, oldExchange],
      );
    } else {
      res = await db.deleteQuery(
        DatabaseHelper.tablePortfolio,
        '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
        [oldCode, oldExchange],
      );
    }
    
    if (res) {
      Stock newStock = Stock.fromPortfolioTuple(
        (await db.getQuery(
          DatabaseHelper.tablePortfolio,
          '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
          [newCode, newExchange],
        ))
            .first,
      );
      res = await newStock.calculateFigures();
    }

    return res;
  }

  static Future<bool> updateTradeLogCodeExchange(String oldCode,
      String oldExchange, String newCode, String newExchange) async {
    return await db.updateConditionally(
      DatabaseHelper.tableTradeLog,
      {
        DatabaseHelper.colCode: newCode,
        DatabaseHelper.colExchange: newExchange
      },
      '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [oldCode, oldExchange],
    );
  }
}
