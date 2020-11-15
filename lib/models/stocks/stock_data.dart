import 'package:folio/models/stocks/current_stock_data.dart';
import 'package:folio/models/stocks/stock.dart';

class StockData {
  Stock _stock;
  CurrentStockData _current;

  static Duration interval = Duration(seconds: 15);

  StockData(Stock stock)
      : _stock = stock,
        assert(stock != null) {
    _current = new CurrentStockData();
  }

  StockData.fromPortfolioTuple(Map<String, dynamic> tuple)
      : assert(tuple != null),
        _stock = Stock.fromPortfolioTuple(tuple) {
    _current = new CurrentStockData();
  }

  String get name => _stock?.name;

  String get exchange => _stock?.exchange;

  String get code => _stock?.code;

  String get key => _stock?.key;

  int get qty => _stock?.qty;

  double get brokerage => _stock?.brokerage;

  set qty(int qty) {
    _stock.qty = qty;
  }

  double get msr => _stock?.minSellRate;

  double get esr => _stock?.estSellRate;

  double get lastValue => _current?.value;

  String get change => _current?.change;

  String get percentChange => _current?.percentageChange;

  String get lastUpdated => _current?.updated;

  int get changeSign => _current?.sign ?? 0;

  double get netAmount => netPerStock == null || qty == null || qty == 0
      ? null
      : (netPerStock * qty).abs();

  double get netPerStock => lastValue == null || msr == null
      ? null
      : ((lastValue - msr) * (1 - brokerage)).abs();

  String get percentNet => msr == null || msr == 0 || netPerStock == null
      ? null
      : (netPerStock / msr).toStringAsFixed(2);

  int get netSign => netPerStock?.sign?.round() ?? 0;

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
}
