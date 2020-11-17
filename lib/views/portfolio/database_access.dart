import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/stock_data.dart';

class DatabaseAccess {
  static DatabaseHelper db = DatabaseHelper();

  static Future<List<StockData>> getPinnedStockData() async {
    List<Map> tuples = await DatabaseHelper().getOrderedQuery(
      DatabaseHelper.tablePortfolio,
      '${DatabaseHelper.colPinned} = ?',
      [1],
      '${DatabaseHelper.colName} ASC, ${DatabaseHelper.colCode} ASC',
    );

    List<StockData> stocks = [];
    tuples.forEach((row) => stocks.add(StockData.fromPortfolioTuple(row)));
    return stocks;
  }

  static Future<List<StockData>> getUnpinnedStockData() async {
    List<Map> tuples = await DatabaseHelper().getOrderedQuery(
      DatabaseHelper.tablePortfolio,
      '${DatabaseHelper.colPinned} = ?',
      [0],
      '${DatabaseHelper.colName} ASC, ${DatabaseHelper.colCode} ASC',
    );

    List<StockData> stocks = [];
    tuples.forEach((row) => stocks.add(StockData.fromPortfolioTuple(row)));
    return stocks;
  }

  static Future<bool> updatePinned(
      String code, String exchange, bool pinned) async {
    return await DatabaseHelper().updateConditionally(
      DatabaseHelper.tablePortfolio,
      {'${DatabaseHelper.colPinned}': pinned ? 1 : 0},
      '${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?',
      [code, exchange],
    );
  }
}
