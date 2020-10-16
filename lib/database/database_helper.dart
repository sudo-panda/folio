import 'dart:async';
import 'dart:io' as io;

import 'package:folio/models/stocks/stock.dart';
import 'package:folio/models/statement.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;

  static String tablePortfolio = 'Portfolio';

  static String colCode = 'code';
  static String colExchange = 'exchange';
  static String colName = 'name';
  static String colKey = 'key';
  static String colQty = 'qty';
  static String colRate = 'rate';
  static String colPinned = 'pinned';

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
    // await db.execute('CREATE TABLE StockAPI ('
    //     'code TEXT,'
    //     'exchange TEXT,'
    //     'key TEXT,'
    //     'PRIMARY KEY (code, exchange)'
    //     ')');
    await db.execute('CREATE TABLE IndexAPI ('
        'code TEXT,'
        'exchange TEXT,'
        'key TEXT,'
        'PRIMARY KEY (code, exchange)'
        ')');
  }

  void _deleteDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "folio.db");
    databaseFactory.deleteDatabase(path);
  }

  void deleteDatabase() async {
    _deleteDb();
  }

  Future<int> saveStock(Stock stock) async {
    var dbClient = await db;
    int res = await dbClient.insert(tablePortfolio, {
      ...stock.toPortfolioTuple(),
      ...{'pinned': 0},
    });
    return res;
  }

  Future<int> saveTuple(Map<String, dynamic> tuple) async {
    var dbClient = await db;
    int res = await dbClient.insert(tablePortfolio, tuple);
    return res;
  }

  Future<int> getCount() async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $tablePortfolio'));
    return count;
  }

  Future<List<Stock>> getAllStocks() async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tablePortfolio);

    List<Stock> stocks = [];
    result.forEach((row) => stocks.add(Stock.fromPortfolioTuple(row)));
    return stocks;
  }

  Future<List<Map>> getAllTuples() async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tablePortfolio);

    return result;
  }

  Future<List<Stock>> getPinnedStocks() async {
    var dbClient = await db;
    List<Map> result = await dbClient
        .query(tablePortfolio, where: '$colPinned = ?', whereArgs: [1]);

    List<Stock> stocks = [];
    result.forEach((row) => stocks.add(Stock.fromPortfolioTuple(row)));
    return stocks;
  }

  Future<List<Map>> getPinnedTuples() async {
    var dbClient = await db;
    List<Map> result = await dbClient
        .query(tablePortfolio, where: '$colPinned = ?', whereArgs: [1]);
    return result;
  }

  Future<List<Stock>> getUnpinnedStocks() async {
    var dbClient = await db;
    List<Map> result = await dbClient
        .query(tablePortfolio, where: '$colPinned = ?', whereArgs: [0]);

    List<Stock> stocks = [];
    result.forEach((row) => stocks.add(Stock.fromPortfolioTuple(row)));
    return stocks;
  }

  Future<List<Map>> getUnpinnedTuples() async {
    var dbClient = await db;
    List<Map> result = await dbClient
        .query(tablePortfolio, where: '$colPinned = ?', whereArgs: [0]);

    return result;
  }

  Future<int> deleteStock(Stock stock) async {
    var dbClient = await db;

    int res = await dbClient.delete(tablePortfolio,
        where: '$colCode = ? and $colExchange = ?',
        whereArgs: [stock.code, stock.exchange]);

    return res;
  }

  Future<bool> updateFromStock(Stock stock) async {
    var dbClient = await db;
    int res = await dbClient.update(
      tablePortfolio,
      stock.toPortfolioTuple(),
      where: "$colCode = ? and $colExchange = ?",
      whereArgs: [stock.code, stock.exchange],
    );
    return res > 0 ? true : false;
  }

  Future<bool> updateName(
      {@required String exchange,
      @required String code,
      @required String name}) async {
    var dbClient = await db;
    int res = await dbClient.update(
      tablePortfolio,
      {'$colName': name},
      where: "$colCode = ? and $colExchange = ?",
      whereArgs: [code, exchange],
    );
    return res > 0 ? true : false;
  }

  Future<bool> updateKey(
      {@required String exchange,
      @required String code,
      @required String key}) async {
    var dbClient = await db;
    int res = await dbClient.update(
      tablePortfolio,
      {'$colKey': key},
      where: "$colCode = ? and $colExchange = ?",
      whereArgs: [code, exchange],
    );
    return res > 0 ? true : false;
  }

  Future<bool> setPinStateStock(Stock stock, bool pin) async {
    var dbClient = await db;
    int res = await dbClient.update(
      tablePortfolio,
      {'pin': pin ? 1 : 0},
      where: "$colCode = ? and $colExchange = ?",
      whereArgs: [stock.code, stock.exchange],
    );
    return res > 0 ? true : false;
  }

  Future updateFromStatements(List<Statement> statements) async {
    var dbClient = await db;
    var doneTransaction = await dbClient.transaction((txn) async {
      int i = 0;
      for (var statement in statements) {
        print(i++);
        List<Map> queryResult = await txn.query(tablePortfolio,
            where: "$colCode = ? and $colExchange = ?",
            whereArgs: [statement.code, statement.exchange]);

        if (queryResult.length == 0) {
          await txn.insert(tablePortfolio, {
            '$colExchange': statement.exchange,
            '$colCode': statement.code,
            '$colQty': statement.qty,
            '$colRate': statement.rate,
            '$colPinned': 0,
          });
        } else {
          Stock stock = Stock.fromPortfolioTuple(queryResult.first);
          stock.trade = statement;
          await txn.update(
            tablePortfolio,
            stock.toPortfolioTuple(),
            where: "$colCode = ? and $colExchange = ?",
            whereArgs: [stock.code, stock.exchange],
          );
        }
      }
    });

    return doneTransaction;
  }
}
