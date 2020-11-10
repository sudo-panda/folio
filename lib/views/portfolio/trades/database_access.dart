import 'package:folio/database/database_helper.dart';
import 'package:folio/models/trades/trade_log.dart';

class DatabaseAccess {
  static DatabaseHelper db = DatabaseHelper();

  static Future<List<TradeLog>> getBuyLogs(String code, String exchange) async {
    List<Map> tuples = await DatabaseHelper().getOrderedQuery(
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
    List<Map> tuples = await DatabaseHelper().getOrderedQuery(
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
}
