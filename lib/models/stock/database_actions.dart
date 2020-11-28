import 'package:folio/helpers/database.dart';
import 'package:folio/models/database/portfolio.dart';
import 'package:folio/models/database/trade_log.dart';

class DatabaseActions {
  static Future<List<TradeLog>> getBuyLogs(String code, String exchange) async {
    List<Map> tuples = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colCode} = ? and ${Db.colExch} = ?',
      [1, code, exchange],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> buyLogs = [];
    tuples.forEach((element) {
      buyLogs.add(TradeLog.fromDbTuple(element));
    });
    return buyLogs;
  }

  static Future<List<TradeLog>> getSellLogs(
      String code, String exchange) async {
    List<Map> tuples = await Db().getOrderedQuery(
      Db.tblTradeLog,
      '${Db.colBought} = ? and ${Db.colCode} = ? and ${Db.colExch} = ?',
      [0, code, exchange],
      '${Db.colDate} ASC, ${Db.colRate} ASC',
    );

    List<TradeLog> sellLogs = [];
    tuples.forEach((element) {
      sellLogs.add(TradeLog.fromDbTuple(element));
    });
    return sellLogs;
  }

  static Future<bool> setStockFigures(Portfolio entry) async {
    int count = await Db().getQueryCount(
      Db.tblPortfolio,
      '${Db.colRowID} = ?',
      [entry.rowid],
    );

    if (count > 0) {
      return await Db().updateConditionally(
        Db.tblPortfolio,
        {
          Db.colQty: entry.qty,
          Db.colMSR: entry.msr,
          Db.colESR: entry.esr,
        },
        '${Db.colRowID} = ?',
        [entry.rowid],
      );
    } else {

      return await Db().insert(
        Db.tblPortfolio,
        entry.toDbTuple(),
      );
    }
  }
}
