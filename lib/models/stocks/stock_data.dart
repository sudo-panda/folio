import 'package:folio/models/stocks/current_stock_data.dart';
import 'package:folio/models/stocks/net.dart';
import 'package:folio/models/stocks/stock.dart';

class StockData {
  Stock _stock;
  CurrentStockData _current;
  Net _net;

  static Duration interval = Duration(seconds: 15);

  static final double brokerage = 0;

  StockData(Stock stock)
      : _stock = stock,
        assert(stock != null) {
    _current = new CurrentStockData();
    _net = new Net();
  }

  StockData.fromPortfolioTuple(Map<String, dynamic> tuple)
      : assert(tuple != null),
        _stock = Stock.fromPortfolioTuple(tuple) {
    _current = new CurrentStockData();
    _net = new Net();
  }

  String get name => _stock?.name;

  String get exchange => _stock?.exchange;

  String get code => _stock?.code;

  String get key => _stock?.key;

  int get qty => _stock?.qty;

  set qty(int qty) {
    _stock.qty = qty;
  }

  double get rate => _stock?.rate;

  double get lastValue => _current?.value;

  String get change => _current?.change;

  String get percentChange => _current?.percentageChange;

  String get lastUpdated => _current?.updated;

  int get changeSign => _current?.sign ?? 0;

  double get netAmount => _net?.amount;

  double get netPerStock => _net?.amountPerStock;

  int get netSign => _net?.sign ?? 0;

  set name(String name) {
    _stock.name = name;
  }

  set current(CurrentStockData currentData) {
    _current.change = currentData?.change ?? _current.change;
    _current.percentageChange =
        currentData?.percentageChange ?? _current.percentageChange;
    _current.sign = currentData?.sign ?? 0;
    _current.updated = currentData?.updated;
    _current.value = currentData?.value;
  }

  set net(Net net) {
    _net.amount = net.amount;
    _net.amountPerStock = net.amountPerStock;
    _net.sign = net.sign;
  }

  void calculateNet() {
    if (_stock?.qty == null || _current?.value == null) {
      return;
    }
    if (_stock?.qty <= 0) {
      _net.amountPerStock = null;
      _net.amount = null;
      _net.sign = 0;
      return;
    }
    _net.amountPerStock = ((_current.value - _stock.rate) * (1 - brokerage));
    _net.amount = (_net.amountPerStock * _stock.qty).abs();
    _net.sign = (_net.amountPerStock.sign).round();
    _net.amountPerStock = _net.amountPerStock.abs();
  }
}
