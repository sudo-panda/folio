import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static final Db _instance = new Db.internal();
  factory Db() => _instance;
  static Database? _db;

  static String tblTracked = 'TrackedTBL';
  static String tblPortfolio = 'PortfolioTBL';
  static String tblTradeLog = 'TradeLogTBL';
  static String tblScrips = 'ScripsTBL';

  static String colStockID = 'stock_id';
  static String colRowID = 'rowid';
  static String colCode = 'code';
  static String colBSECode = 'bse_code';
  static String colNSECode = 'nse_code';
  static String colExch = 'exchange';
  static String colName = 'name';
  static String colKey = 'key';
  static String colQty = 'qty';
  static String colGrossQty = 'gross_qty';
  static String colRate = 'rate';
  static String colAvgRate = 'avg_rate';
  static String colMSR = 'min_sell_rate';
  static String colESR = 'est_sell_rate';
  static String colPinned = 'pinned';
  static String colBought = 'bought';
  static String colDate = 'date';

  Future<Database> get db async {
    return _db ?? (_db = await initDb());
  }

  Db.internal();

  initDb() async {
    String path = await getDbPath();
    var theDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return theDb;
  }

  Future<String> getDbPath() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, "folio.db");
  }

  void _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $tblTracked ('
        '$colStockID INTEGER,' // Not UNIQUE as one of BSE and one of NSE
        '$colCode TEXT,'
        '$colExch TEXT,'
        '$colPinned INTEGER,'
        'PRIMARY KEY ($colCode, $colExch)'
        ')');
    await db.execute('CREATE TABLE $tblPortfolio ('
        '$colRowID INTEGER PRIMARY KEY, '
        '$colStockID INTEGER UNIQUE,'
        '$colGrossQty INTEGER, '
        '$colAvgRate REAL, '
        '$colMSR REAL, '
        '$colESR REAL'
        ')');
    await db.execute('CREATE TABLE $tblTradeLog ('
        '$colRowID INTEGER PRIMARY KEY, '
        '$colStockID INTEGER, '
        '$colDate TEXT, '
        '$colCode TEXT, '
        '$colExch TEXT, '
        '$colBought INTEGER, '
        '$colQty INTEGER, '
        '$colRate REAL'
        ')');
    await db.execute('CREATE TABLE $tblScrips ('
        '$colRowID INTEGER PRIMARY KEY, '
        '$colBSECode TEXT UNIQUE, '
        '$colNSECode TEXT UNIQUE, '
        '$colName TEXT'
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

  Future<int?> getTotalCount(String table) async {
    var dbClient = await db;
    int? count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $table'));
    return count;
  }

  Future<List<Map>> getAllTuples(String table) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(table);

    return result;
  }

  Future<List<Map<String, dynamic>>> getRawQuery(String query) async {
    var dbClient = await db;
    return await dbClient.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getQuery(
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

  Future<List<Map<String, dynamic>>> getLimitedOrdered(
      String table, int limit, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table, limit: limit, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> getOrderedQuery(String table, String where,
      List<dynamic> whereArgs, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> getOrdered(
      String table, String orderBy) async {
    var dbClient = await db;
    return await dbClient.query(table, orderBy: orderBy);
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
      String where, List<dynamic> whereArgs) async {
    var dbClient = await db;
    int res = await dbClient.update(
      table,
      tuple,
      where: where,
      whereArgs: whereArgs,
    );
    return res > 0 ? true : false;
  }

  Future<T> transact<T>(Future<T> Function(Transaction) transaction) async {
    var dbClient = await db;
    return await dbClient.transaction(transaction);
  }

  Future<List<Map<String, dynamic>>> getPortfolioView() async {
    return Db().getRawQuery(""
        "SELECT "
        "P.${Db.colRowID} AS ${Db.colRowID}, "
        "P.${Db.colStockID} AS ${Db.colStockID}, "
        "S.${Db.colName} AS ${Db.colName}, "
        "S.${Db.colNSECode} AS ${Db.colNSECode}, "
        "S.${Db.colBSECode} AS ${Db.colBSECode}, "
        "${Db.colGrossQty}, ${Db.colAvgRate}, ${Db.colMSR}, ${Db.colESR}, "
        ""
        "FROM ${Db.tblPortfolio} P "
        "LEFT JOIN ${Db.tblScrips} S "
        "ON P.${Db.colStockID} = S.${Db.colRowID} ");
  }
}
