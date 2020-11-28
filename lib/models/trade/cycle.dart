import 'package:folio/models/trade/invoice.dart';

class TradeCycle {
  DateTime date;
  List<Invoice> invoices;
  int sellQty;
  double sellRate;
  double _brokerage;

  int netQty;

  TradeCycle(this.date, this.sellQty, this.sellRate)
      : netQty = -sellQty,
        invoices = [],
        _brokerage = 0.02;

  int addBuyLog(int qty, double rate) {
    if (qty < -this.netQty) {
      this.netQty += qty;
      invoices.add(Invoice(qty, rate));
      return 0;
    } else {
      qty += this.netQty;
      invoices.add(Invoice(-this.netQty, rate));
      this.netQty = 0;
      return qty;
    }
  }

  double get net {
    double buyAmount = 0;
    invoices.forEach((element) {
      buyAmount += element.qty * element.rate;
    });
    return ((sellRate * sellQty) * (1 - _brokerage)) -
        (buyAmount * (1 + _brokerage));
  }

  double get brokerage {
    double buyAmount = 0;
    invoices.forEach((element) {
      buyAmount += element.qty * element.rate;
    });
    return ((sellRate * sellQty) * _brokerage) + (buyAmount * _brokerage);
  }

  @override
  String toString() {
    String ret = "\n$sellQty x $sellRate";
    invoices.forEach((element) {
      ret += "\n\t${element.qty} * ${element.rate}";
    });
    return ret;
  }
}
