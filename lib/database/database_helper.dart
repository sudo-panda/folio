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
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "folio.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $tablePortfolio ('
        '$colCode TEXT,'
        '$colExchange TEXT,'
        '$colName TEXT,'
        '$colKey TEXT,'
        '$colQty INTEGER,'
        '$colRate REAL,'
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
    // await db.execute('CREATE TABLE IndexAPI ('
    //     'code TEXT,'
    //     'exchange TEXT,'
    //     'key TEXT,'
    //     'PRIMARY KEY (code, exchange)'
    //     ')');
  }

  void _deleteDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "folio.db");
    databaseFactory.deleteDatabase(path);
    _db = await initDb();
  }

  void deleteDatabase() async {
    _deleteDb();
  }

  Future<int> saveTuple(String table, Map<String, dynamic> tuple) async {
    var dbClient = await db;
    int res = await dbClient.insert(table, tuple);
    return res;
  }

  Future<int> getCount(String table) async {
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

  Future<List<Map>> getOrderedQuery(
      String table, String where, List<dynamic> whereArgs, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
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
    var doneTransaction = await dbClient.transaction((txn) async {
      int i = 0;
      for (var tradeLog in tradeLogs) {
        print(i++);
        try {
          await txn.insert(tableTradeLog, tradeLog.toTradeLogTuple());
        } on DatabaseException catch (e) {
          if (e.isUniqueConstraintError()) {
            continue;
          } else {
            throw e;
          }
        }

        try {
          await txn.insert(tablePortfolio, {
            '$colExchange': tradeLog.exchange,
            '$colCode': tradeLog.code,
            '$colQty': tradeLog.qty,
            '$colRate': tradeLog.rate,
            '$colPinned': 0,
          });
        } on DatabaseException catch (e) {

          if (e.isUniqueConstraintError()) {

            List<Map> queryResult = await txn.query(tablePortfolio,
                where: "$colCode = ? and $colExchange = ?",
                whereArgs: [tradeLog.code, tradeLog.exchange]);

            Stock stock = Stock.fromPortfolioTuple(queryResult.first);

            stock.trade = tradeLog;

            await txn.update(
              tablePortfolio,
              stock.toPortfolioTuple(),
              where: "$colCode = ? and $colExchange = ?",
              whereArgs: [stock.code, stock.exchange],
            );

          } else {
            throw e;
          }
        }
      }
    });

    return doneTransaction;
  }
}
