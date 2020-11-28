import 'package:folio/models/database/portfolio.dart';
import 'package:folio/models/database/tracked.dart';
import 'package:folio/models/stock/latest.dart';
import 'package:folio/state/globals.dart';

class Stock {
  Portfolio _portfolio;
  Tracked _tracked;
  Latest _latest;
  static Duration interval = Duration(seconds: 15);
  bool isVisible = true;

  Stock.fromDbTuple(Map<String, dynamic> tuple)
      : assert(tuple != null),
        _portfolio = Portfolio.fromDbTuple(tuple),
        _tracked = Tracked.fromDbTuple(tuple),
        _latest = Latest();

  int get id => _portfolio.rowid;

  String get name => _tracked?.name;

  String get exchange => _tracked?.exchange;

  String get code => _tracked?.code;

  int get qty => _portfolio?.qty;

  double get msr => _portfolio?.msr;

  double get esr => _portfolio?.esr;

  double get lastValue => _latest?.value;

  String get change => _latest?.change;

  String get percentChange => _latest?.percentageChange;

  String get lastUpdated => _latest?.updated;

  int get changeSign => _latest?.sign ?? 0;

  double get netAmount => netPerStock == null || qty == null || qty == 0
      ? null
      : (netPerStock * qty).abs();

  double get netPerStock => lastValue == null || msr == null
      ? null
      : ((lastValue - msr) * (1 - Globals.brokerage)).abs();

  String get percentNet => msr == null || msr == 0 || netPerStock == null
      ? null
      : (netPerStock / msr).toStringAsFixed(2);

  int get netSign => netPerStock?.sign?.round() ?? 0;

  bool get pinned => _tracked.pinned;

  String get bseCode => _portfolio.bseCode;

  String get nseCode => _portfolio.nseCode;

  set pinned(bool pin) {
    _tracked.pinned = pin;
  }

  set name(String name) {
    _tracked.name = name;
  }

  set bseCode(String code) {
    _portfolio.bseCode = code;

    if (_tracked.exchange == "BSE") {
      _tracked.code = code;
    }
  }

  set nseCode(String code) {
    _portfolio.nseCode = code;

    if (_tracked.exchange == "NSE") {
      _tracked.code = code;
    }
  }

  set latest(Latest data) {
    _latest.change = data?.change ?? _latest.change;
    _latest.percentageChange =
        data?.percentageChange ?? _latest.percentageChange;
    _latest.sign = data?.sign ?? 0;
    _latest.updated = data?.updated;
    _latest.value = data?.value;
  }
}
