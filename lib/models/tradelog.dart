import 'package:folio/database/database_helper.dart';

class TradeLog {
  DateTime _datetime;
  String _code;
  String _exchange;
  bool _bought;
  int _qty;
  double _rate;

  TradeLog(this._datetime, this._code, this._exchange, this._bought, this._qty,
      this._rate);

  String get code => _code;

  String get exchange => _exchange;

  bool get bought => _bought;

  int get qty => _qty;

  double get rate => _rate;

  Map<String, dynamic> toTradeLogTuple() {
    return {
      '${DatabaseHelper.colDate}': _datetime.year.toString() +
          '-' +
          _datetime.month.toString() +
          '-' +
          _datetime.day.toString(),
      '${DatabaseHelper.colCode}' : _code,
      '${DatabaseHelper.colExchange}' : _exchange,
      '${DatabaseHelper.colBought}' : _bought ? 1 : 0,
      '${DatabaseHelper.colQty}' : _qty,
      '${DatabaseHelper.colRate}' : _rate,
    };
  }
}
