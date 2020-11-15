import 'package:folio/database/database_helper.dart';
import 'package:folio/models/trades/trade_log.dart';

class DatabaseAccess {
  static DatabaseHelper db = DatabaseHelper();

  static Future<DateTime> getRecentDate() async {
    List<Map> tuples = await DatabaseHelper().getLimitedOrdered(
      DatabaseHelper.tableTradeLog,
      1,
      '${DatabaseHelper.colDate} DESC',
    );
  
    return tuples.isEmpty ? null : TradeLog.fromTradeLogTuple(tuples.first).date;
  }
}
