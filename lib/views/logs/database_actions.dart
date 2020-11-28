import 'package:folio/helpers/database.dart';
import 'package:folio/models/database/trade_log.dart';

class DatabaseActions {
  static Future<List<TradeLog>> getAllLogs() async {
    List<Map> tuples = await Db()
        .getOrdered(Db.tblTradeLog, '${Db.colDate} ASC, ${Db.colCode} ASC');

    List<TradeLog> logs = [];
    tuples.forEach((row) => logs.add(TradeLog.fromDbTuple(row)));
    return logs;
  }
}
