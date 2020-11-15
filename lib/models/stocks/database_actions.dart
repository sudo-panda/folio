import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/stock.dart';
import 'package:folio/models/trades/trade_log.dart';

class DatabaseActions {
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

  static Future<bool> setStockFigures(Stock stock) async {
    int count = await DatabaseHelper().getQueryCount(
      DatabaseHelper.tablePortfolio,
      '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [stock.code, stock.exchange],
    );

    if (count > 0) {
      return await DatabaseHelper().updateConditionally(
        DatabaseHelper.tablePortfolio,
        {
          DatabaseHelper.colQty: stock.qty,
          DatabaseHelper.colMinSellRate: stock.minSellRate,
          DatabaseHelper.colEstSellRate: stock.estSellRate
        },
        '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
        [stock.code, stock.exchange],
      );
    } else {
      var tuple = stock.toPortfolioTuple();
      tuple.addAll({DatabaseHelper.colPinned: 0});
      
      return await DatabaseHelper().insert(
        DatabaseHelper.tablePortfolio,
        tuple,
      );
    }
  }
}
