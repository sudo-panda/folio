import 'dart:async';
import 'dart:io' as io;

import 'package:folio/models/stocks/stock.dart';
import 'package:folio/models/trades/trade_log.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;

  static String tablePortfolio = 'Portfolio';
  static String tableTradeLog = 'TradeLog';

  static String colCode = 'code';
  static String colExchange = 'exchange';
  static String colName = 'name';
  static String colKey = 'key';
  static String colQty = 'qty';
  static String colRate = 'rate';
  static String colMinSellRate = 'min_sell_rate';
  static String colEstSellRate = 'est_sell_rate';
  static String colPinned = 'pinned';
  static String colBought = 'bought';
  static String colDate = 'date';

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    String path = await getDbPath();
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  Future<String> getDbPath() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, "folio.db");
  }

  void _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $tablePortfolio ('
        '$colCode TEXT,'
        '$colExchange TEXT,'
        '$colName TEXT,'
        '$colKey TEXT,'
        '$colQty INTEGER,'
        '$colMinSellRate REAL,'
        '$colEstSellRate REAL,'
        '$colPinned INTEGER,'
        'PRIMARY KEY ($colCode, $colExchange)'
        ')');
    await db.execute('CREATE TABLE $tableTradeLog ('
        '$colDate TEXT,'
        '$colCode TEXT,'
        '$colExchange TEXT,'
        '$colBought INTEGER,'
        '$colQty INTEGER,'
        '$colRate REAL,'
        'PRIMARY KEY ($colDate, $colCode, $colExchange, $colBought, $colQty, $colRate)'
        ')');
  }

  void deleteDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "folio.db");
    databaseFactory.deleteDatabase(path);
    _db = null;
  }

  void deleteDbThenInit() async {
    deleteDb();
    _db = await initDb();
  }

  Future<int> saveTuple(String table, Map<String, dynamic> tuple) async {
    var dbClient = await db;
    int res = await dbClient.insert(table, tuple);
    return res;
  }

  Future<int> getTotalCount(String table) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $table'));
    return count;
  }

  Future<List<Map>> getAllTuples(String table) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(table);

    return result;
  }

  Future<List<Map>> getQuery(
      String table, String where, List<dynamic> whereArgs) async {
    var dbClient = await db;
    return await dbClient.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> getQueryCount(
      String table, String where, List<dynamic> whereArgs) async {
    var dbClient = await db;
    return (await dbClient.query(table, where: where, whereArgs: whereArgs))
        .length;
  }

  Future<List<Map>> getLimitedOrdered(
      String table, int limit, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table, limit: limit, orderBy: orderBy);
  }

  Future<List<Map>> getOrderedQuery(String table, String where,
      List<dynamic> whereArgs, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<bool> deleteQuery(
      String table, String where, List<dynamic> whereArgs) async {
    var dbClient = await db;
    int res = await dbClient.delete(table, where: where, whereArgs: whereArgs);
    return res > 0 ? true : false;
  }

  Future<bool> insert(String table, Map<String, dynamic> tuple) async {
    var dbClient = await db;
    int res = await dbClient.insert(table, tuple);
    return res > 0 ? true : false;
  }

  Future<bool> updateAll(String table, Map<String, dynamic> tuple) async {
    var dbClient = await db;
    int res = await dbClient.update(table, tuple);
    return res > 0 ? true : false;
  }

  Future<bool> updateConditionally(String table, Map<String, dynamic> tuple,
      String where, List<String> whereArgs) async {
    var dbClient = await db;
    int res = await dbClient.update(
      table,
      tuple,
      where: where,
      whereArgs: whereArgs,
    );
    return res > 0 ? true : false;
  }

  Future updateFromTradeLogs(List<TradeLog> tradeLogs) async {
    var dbClient = await db;

    List<Map<String, String>> recalc = [];

    var doneTransaction = await dbClient.transaction(
      (txn) async {
        int i = 0;
        for (var tradeLog in tradeLogs) {
          print(++i);
          try {
            await txn.insert(tableTradeLog, tradeLog.toTradeLogTuple());
          } on DatabaseException catch (e) {
            if (e.isUniqueConstraintError()) {
              continue;
            } else {
              throw e;
            }
          }

          bool toAdd = true;

          for (var element in recalc) {
            if (element["code"] == tradeLog.code &&
                element["exchange"] == tradeLog.exchange) {
              toAdd = false;
              break;
            }
          }

          if (toAdd) {
            recalc.add({"code": tradeLog.code, "exchange": tradeLog.exchange});
          }
        }
      },
    );

    for (var element in recalc) {
      List<Map> queryResult = await dbClient.query(tablePortfolio,
          where: "$colCode = ? and $colExchange = ?",
          whereArgs: [element["code"], element["exchange"]]);

      Stock stock;

      if (queryResult.isEmpty) {
        stock = Stock(element["code"], element["exchange"]);
      } else {
        stock = Stock.fromPortfolioTuple(queryResult.first);
      }

      print(
          element["code"] + ":" + (await stock.calculateFigures()).toString());
    }

    print(await getTotalCount(tablePortfolio));

    return doneTransaction;
  }
}
