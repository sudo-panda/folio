import 'package:folio/services/database/database.dart';

class Portfolio {
  late int? stockID;
  late String? name;
  late String? bseCode;
  late String? nseCode;
  late int? qty;
  late double? rate;
  late double? msr;
  late double? esr;

  Portfolio.fromDbTuple(Map<String, dynamic> tuple) {
    stockID = tuple[Db.colStockID];
    name = tuple[Db.colName];
    bseCode = tuple[Db.colBSECode];
    nseCode = tuple[Db.colNSECode];
    qty = tuple[Db.colGrossQty];
    rate = tuple[Db.colAvgRate];
    msr = tuple[Db.colMSR];
    esr = tuple[Db.colESR];
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colStockID: stockID,
      Db.colBSECode: bseCode,
      Db.colNSECode: nseCode,
      Db.colGrossQty: qty,
      Db.colAvgRate: rate,
      Db.colMSR: msr,
      Db.colESR: esr,
    };
  }
}
