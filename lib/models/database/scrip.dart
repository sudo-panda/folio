import 'package:folio/helpers/database_actions.dart';
import 'package:folio/services/database/database.dart';

class Scrip {
  int stockID = -1;
  late String name;
  String? bseCode;
  String? nseCode;
  List<String> oldBSECodes = [];
  List<String> oldNSECodes = [];

  Scrip(this.name);

  Scrip.fromDbTuple(Map<String, dynamic> tuple) {
    stockID = tuple[Db.colRowID];
    name = tuple[Db.colName];
    bseCode = tuple[Db.colBSECode];
    nseCode = tuple[Db.colNSECode];
    oldBSECodes =
        tuple[Db.colOldBSECodes]?.split(DatabaseActions.delimiter) ?? [];
    oldNSECodes =
        tuple[Db.colOldNSECodes]?.split(DatabaseActions.delimiter) ?? [];
    oldBSECodes.remove("");
    oldNSECodes.remove("");
  }

  Map<String, dynamic> toDbTuple() {
    return {
      Db.colName: name,
      Db.colBSECode: bseCode,
      Db.colNSECode: nseCode,
      Db.colOldBSECodes: oldBSECodes.join(DatabaseActions.delimiter),
      Db.colOldNSECodes: oldNSECodes.join(DatabaseActions.delimiter),
    };
  }

  String? code(String exchange) {
    switch (exchange) {
      case "BSE":
        return bseCode;
      case "NSE":
        return nseCode;
    }
    throw Exception("Wrong exchange passed to code() of ${this.toString()}");
  }

  List<String> oldCodes(String exchange) {
    switch (exchange) {
      case "BSE":
        return oldBSECodes;
      case "NSE":
        return oldNSECodes;
    }
    throw Exception(
        "Wrong exchange passed to oldCodes() of ${this.toString()}");
  }

  void setCode(String exchange, String? code) {
    switch (exchange) {
      case "BSE":
        bseCode = code;
        return;
      case "NSE":
        nseCode = code;
        return;
    }
    throw Exception("Wrong exchange passed to setCode() of ${this.toString()}");
  }

  void setOldCodes(String exchange, List<String> oldCodes) {
    switch (exchange) {
      case "BSE":
        oldBSECodes = oldCodes;
        return;
      case "NSE":
        oldNSECodes = oldCodes;
        return;
    }
    throw Exception(
        "Wrong exchange passed to setOldCodes() of ${this.toString()}");
  }
}
