class FileLog {
  DateTime? date;
  String? name;
  String? bseCode;
  String? nseCode;
  String? exchange;
  bool? bought;
  int? qty;
  double? rate;

  FileLog(this.date, this.name, this.bseCode, this.nseCode, this.exchange, this.bought, this.qty,
      this.rate);

  String? get code {
    switch (exchange) {
      case "BSE":
        return bseCode;
      case "NSE":
        return nseCode;
      default:
        return null;
    }
  }

  bool get isNSECodeRequired {
    switch (exchange) {
      case "BSE":
        return false;
      case "NSE":
        return true;
      default:
        return false;
    }
  }

  bool get isBSECodeRequired {
    switch (exchange) {
      case "BSE":
        return true;
      case "NSE":
        return false;
      default:
        return false;
    }
  }
}

class ParsedFileLogs {
  List<FileLog> validLogs = [];
  List<FileLog> invalidLogs = [];
}