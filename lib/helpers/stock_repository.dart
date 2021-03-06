import 'package:folio/services/database/database.dart';
import 'package:folio/models/stock/latest.dart';
import 'package:folio/services/query/query_api.dart';

class StockRepository {
  static Stream<Latest> getPeriodicLatest(String code, String exchange) async* {
    yield await QueryAPI.getCurrentData(exchange: exchange, code: code);

    yield* Stream.periodic(Duration(seconds: 30), (_) {
      return QueryAPI.getCurrentData(exchange: exchange, code: code);
    }).asyncMap(
      (value) async => await value,
    );
  }

  static Future<String> getName(String code, String exchange) async {
    String name = await QueryAPI.getName(exchange: exchange, code: code);
    await Db().updateConditionally(
        Db.tblTracked,
        {Db.colName: name?.toUpperCase()},
        '${Db.colCode} = ? and ${Db.colExch} = ?',
        [code, exchange]);
    return name?.toUpperCase();
  }

  static Future<Latest> getOnceLatest(String code, String exchange) async {
    return await QueryAPI.getCurrentData(exchange: exchange, code: code);
  }

  
}
