import 'package:folio/services/database/database.dart';

class Portfolio {
  late int? stockID;
  late String? name;
  late String? bseCode;
  late String? nseCode;
  late int? qty;
  late double? msr;
  late double? esr;

  Portfolio.fromDbTuple(Map<String, dynamic> tuple) {
    stockID = tuple[Db.colStockID];
    bseCode = tuple[Db.colBSECode];
    nseCode = tuple[Db.colNSECode];
    qty = tuple[Db.colGrossQty];
    msr = tuple[Db.colMSR];
    esr = tuple[Db.colESR];
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colStockID: stockID,
      Db.colBSECode: bseCode,
      Db.colNSECode: nseCode,
      Db.colGrossQty: qty,
      Db.colMSR: msr,
      Db.colESR: esr,
    };
  }
}
