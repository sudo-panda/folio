// import 'package:folio/services/search.dart';
import 'package:folio/models/trades/trade_log.dart';

class Stock {
  String name;
  String _exchange;
  String _key;
  String _code;
  int qty;
  double _rate;
  Future _isInitialized;

  Stock(String name, String code, String exchange, String key)
      : assert(name != null),
        assert(code != null),
        assert(exchange != null),
        assert(key != null),
        this.name = name,
        this._code = code,
        this._exchange = exchange,
        this._key = key {
    qty = 0;
    _rate = 0.0;
  }

  Stock.fromPortfolioTuple(Map<String, dynamic> tuple) {
    this.name = tuple["name"];
    this._exchange = tuple["exchange"];
    this._key = tuple["key"];
    this._code = tuple["code"];
    this.qty = tuple["qty"];
    this._rate = tuple["rate"];
  }

  String get exchange => _exchange;

  String get key => _key;

  String get code => _code;

  double get rate => _rate;

  Future get initializationDone => _isInitialized;

  set trade(TradeLog statement) {
    var newQty = (statement.bought ? 1 : -1) * statement.qty;
    if ((this.qty + newQty) == 0) {
      this._rate = 0;
    } else {
      this._rate = (this._rate * this.qty + statement.rate * newQty) /
          (this.qty + newQty);
    }
    this.qty += newQty;
  }

  Map<String, dynamic> toPortfolioTuple() {
    return {
      'name': this.name,
      'exchange': this._exchange,
      'code': this._code,
      'key': this._key,
      'qty': this.qty,
      'rate': this._rate,
    };
  }
}
