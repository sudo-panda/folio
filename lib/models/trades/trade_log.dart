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

  TradeLog.fromTradeLogTuple(Map<String, dynamic> tuple)
      : _code = tuple['${DatabaseHelper.colCode}'],
        _exchange = tuple['${DatabaseHelper.colExchange}'],
        _bought = tuple['${DatabaseHelper.colBought}'] == 1 ? true : false,
        _qty = tuple['${DatabaseHelper.colQty}'],
        _rate = tuple['${DatabaseHelper.colRate}'],
        _datetime = DateTime.utc(
            int.parse(tuple['${DatabaseHelper.colDate}']
                .substring(0, tuple['${DatabaseHelper.colDate}'].indexOf('-'))),
            int.parse(tuple['${DatabaseHelper.colDate}'].substring(
                tuple['${DatabaseHelper.colDate}'].indexOf('-') + 1,
                tuple['${DatabaseHelper.colDate}'].lastIndexOf('-'))),
            int.parse(tuple['${DatabaseHelper.colDate}'].substring(
                tuple['${DatabaseHelper.colDate}'].lastIndexOf('-') + 1)));

  DateTime get date => _datetime;

  String get code => _code;

  String get exchange => _exchange;

  bool get bought => _bought;

  int get qty => _qty;

  double get rate => _rate;

  Map<String, dynamic> toTradeLogTuple() {
    return {
      '${DatabaseHelper.colDate}': _datetime.year.toString().padLeft(4, '0') +
          '-' +
          _datetime.month.toString().padLeft(2, '0') +
          '-' +
          _datetime.day.toString().padLeft(2, '0'),
      '${DatabaseHelper.colCode}': _code,
      '${DatabaseHelper.colExchange}': _exchange,
      '${DatabaseHelper.colBought}': _bought ? 1 : 0,
      '${DatabaseHelper.colQty}': _qty,
      '${DatabaseHelper.colRate}': _rate,
    };
  }

  @override
  String toString() {
    return "\n" + date.day.toString().padLeft(2, '0') +
        '/' +
        date.month.toString().padLeft(2, '0') +
        '/' +
        date.year.toString().padLeft(4, '0') +
        ', cd:' +
        code.toString() +
        ', ex:' +
        exchange.toString() +
        ', bt:' +
        bought.toString() +
        ', qt:' +
        qty.toString() +
        ', rt:' +
        rate.toStringAsFixed(2);
  }
}
