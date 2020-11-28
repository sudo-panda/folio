import 'package:folio/helpers/database.dart';

class Portfolio {
  int rowid;
  String bseCode;
  String nseCode;
  int qty;
  double msr;
  double esr;

  Portfolio.fromDbTuple(Map<String, dynamic> tuple) {
    rowid = tuple["rowid"];
    bseCode = tuple[Db.colBSECode];
    nseCode = tuple[Db.colNSECode];
    qty = tuple[Db.colQty];
    msr = tuple[Db.colMSR];
    esr = tuple[Db.colESR];
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colBSECode: bseCode,
      Db.colNSECode: nseCode,
      Db.colQty: qty,
      Db.colMSR: msr,
      Db.colESR: esr,
    };
  }
}
