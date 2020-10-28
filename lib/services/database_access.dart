import 'package:folio/database/database_helper.dart';

class DatabaseAccess {
  static DatabaseHelper db = DatabaseHelper();

  static Future<bool> updateKey(String code, String exchange, String key) async {
    return await DatabaseHelper().updateConditionally(
      DatabaseHelper.tablePortfolio,
      {'${DatabaseHelper.colKey}': key},
      "${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?",
      [code, exchange],
    );
  }
}
