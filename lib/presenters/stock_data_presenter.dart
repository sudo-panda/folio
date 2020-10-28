import 'dart:async';

import 'package:folio/contracts/stock_tile_contract.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/services/query/query_api.dart';

class StockDataPresenter {
  StockTileContract _view;
  StockData _stockData;
  Timer _timer;

  StockDataPresenter(this._view, this._stockData) {
    if (_stockData.name == null) _assignName();

    _timerCallback(_timer);
    _timer = new Timer.periodic(Duration(seconds: 30), _timerCallback);
  }

  void _assignName() async {
    var code = _stockData?.code;
    var exchange = _stockData?.exchange;
    var name = await QueryAPI.getName(exchange: exchange, code: code);

    DatabaseHelper().updateConditionally(
      DatabaseHelper.tablePortfolio,
      {'${DatabaseHelper.colName}': name},
      "${DatabaseHelper.colCode} = ? and ${DatabaseHelper.colExchange} = ?",
      [code, exchange],
    );

    _stockData?.name = name;
  }

  void refreshNow() {
    _timerCallback(_timer);
  }

  void _timerCallback(Timer t) async {
    var newData = await QueryAPI.getCurrentData(
        exchange: _stockData.exchange,
        code: _stockData.code,
        key: _stockData.key);

    _view?.currentStockDataUpdate(newData);
  }

  void dispose() {
    _view = null;
    _stockData = null;
    _timer.cancel();
    _timer = null;
  }
}
