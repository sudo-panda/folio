import 'package:folio/services/database/database.dart';

class Tracked {
  late String code;
  late String exchange;
  late String? name;
  late bool pinned;

  Tracked.fromDbTuple(Map<String, dynamic> tuple) {
    code = tuple[Db.colCode];
    exchange = tuple[Db.colExch];
    name = tuple[Db.colName];
    pinned = (tuple[Db.colPinned] ?? 0) > 0;
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colCode: code,
      Db.colExch: exchange,
      Db.colName: name,
      Db.colPinned: pinned ? 1 : 0,
    };
  }
}
