import 'package:folio/database/database_helper.dart';
import 'package:folio/models/stocks/database_actions.dart';

class Stock {
  String name;
  String exchange;
  String key;
  String code;
  int qty;
  double minSellRate;
  double estSellRate;
  double brokerage = 0.02;
  double requiredProfit = 0.1;
  Future _isInitialized;

  Stock(String code, String exchange)
      : assert(code != null),
        assert(exchange != null),
        this.code = code,
        this.exchange = exchange {
    qty = 0;
  }

  Stock.fromPortfolioTuple(Map<String, dynamic> tuple) {
    this.name = tuple[DatabaseHelper.colName];
    this.exchange = tuple["exchange"];
    this.key = tuple[DatabaseHelper.colKey];
    this.code = tuple[DatabaseHelper.colCode];
    this.qty = tuple[DatabaseHelper.colQty];
    this.minSellRate = tuple[DatabaseHelper.colMinSellRate];
    this.estSellRate = tuple[DatabaseHelper.colEstSellRate];
  }

  Future get initializationDone => _isInitialized;

  Future<bool> calculateFigures() async {
    var buyLogs = await DatabaseActions.getBuyLogs(code, exchange);
    var sellLogs = await DatabaseActions.getSellLogs(code, exchange);

    qty = null;
    minSellRate = null;
    estSellRate = null;

    int b = 0, s = 0;
    double totalNet = 0, totalProfitDifference = 0;

    while (s < sellLogs.length) {
      int buyQty = sellLogs[s].qty;
      double avgBuyRate = 0.0;

      // calculate avgBuyRate for the sold stocks
      while (buyQty > 0) {
        if (b >= buyLogs.length) {
          await DatabaseActions.setStockFigures(this);
          return false;
        }

        if (buyLogs[b].qty > buyQty) {
          buyLogs[b].qty -= buyQty;
          avgBuyRate = (avgBuyRate * (sellLogs[s].qty - buyQty) +
                  buyQty * buyLogs[b].rate) /
              sellLogs[s].qty;
          buyQty = 0;
        } else {
          avgBuyRate = (avgBuyRate * (sellLogs[s].qty - buyQty) +
                  buyLogs[b].qty * buyLogs[b].rate) /
              (sellLogs[s].qty - buyQty + buyLogs[b].qty);
          buyQty -= buyLogs[b].qty;
          buyLogs[b].qty = 0;
          b++;
        }
      }

      // calculate the Costs
      var avgBuyCost = avgBuyRate + avgBuyRate * brokerage;
      var avgSellCost = sellLogs[s].rate - sellLogs[s].rate * brokerage;

      totalNet += sellLogs[s].qty * (avgSellCost - avgBuyCost);
      // Does let past profits balance out future losses
      totalNet = totalNet > 0 ? 0 : totalNet;

      var estimatedSellRate = avgBuyCost + avgBuyCost * requiredProfit;
      totalProfitDifference +=
          sellLogs[s].qty * (avgSellCost - estimatedSellRate);

      // Uncomment if you want overall profit to be greater than requiredProfit
      totalProfitDifference =
          totalProfitDifference > 0 ? 0 : totalProfitDifference;

      s++;
    }

    qty = 0;
    minSellRate = 0;
    estSellRate = 0;

    double avgBuyRate = 0;

    for (; b < buyLogs.length; b++) {
      avgBuyRate = (qty * avgBuyRate + buyLogs[b].qty * buyLogs[b].rate) /
          (qty + buyLogs[b].qty);
      qty += buyLogs[b].qty;
    }

    if (qty != 0) {
      var avgBuyCost = avgBuyRate + avgBuyRate * brokerage;
      minSellRate = ((avgBuyCost * qty - totalNet) / qty) * (1 + brokerage);

      var profitableSellRate = avgBuyCost + avgBuyCost * requiredProfit;
      estSellRate = ((profitableSellRate * qty - totalProfitDifference) / qty) *
          (1 + brokerage);
    } else {
      minSellRate = null;
      estSellRate = null;
    }

    if (await DatabaseActions.setStockFigures(this)) {
      return true;
    } else {
      qty = null;
      minSellRate = null;
      estSellRate = null;
      return false;
    }
  }

  Map<String, dynamic> toPortfolioTuple() {
    return {
      DatabaseHelper.colName: this.name,
      DatabaseHelper.colExchange: this.exchange,
      DatabaseHelper.colCode: this.code,
      DatabaseHelper.colKey: this.key,
      DatabaseHelper.colQty: this.qty,
      DatabaseHelper.colMinSellRate: this.minSellRate,
      DatabaseHelper.colEstSellRate: this.estSellRate,
    };
  }
}
