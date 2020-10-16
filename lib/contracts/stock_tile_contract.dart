import 'package:folio/models/stocks/current_stock_data.dart';

abstract class StockTileContract {
  void currentStockDataUpdate(CurrentStockData newData);
}
