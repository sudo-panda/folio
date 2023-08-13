import 'package:collection/collection.dart';
import 'package:folio/models/trade/cycle.dart';
import 'package:folio/models/database/trade_log.dart';

class TradeSummary {
  List<TradeLog> portfolio = [];
  List<TradeCycle> cycles = [];
  bool incorrect;

  Future<List<TradeLog>> _buyLogsFuture;
  Future<List<TradeLog>> _sellLogsFuture;

  TradeSummary(this._buyLogsFuture, this._sellLogsFuture) : incorrect = false;

  TradeCycle? computeCycle(int sellQty, double sellRate) {
    int b = 0;
    var cycle = TradeCycle(DateTime.now(), sellQty, sellRate);

    while (cycle.netQty < 0) {
      if (b >= portfolio.length) {
        return null;
      }
      var remaining = cycle.addBuyLog(portfolio[b].qty, portfolio[b].rate);
      if (remaining == 0) {
        b++;
      }
    }

    return cycle;
  }

  Future<TradeSummary> calculateSummary(int ordering) {
    switch (ordering) {
      case 0:
        return _cheapestFirst();

      case 1:
        return _oldestFirst();

      default:
        return _cheapestFirst();
    }
  }

  Future<TradeSummary> _cheapestFirst() async {
    var buyLogs = await _buyLogsFuture;
    var sellLogs = await _sellLogsFuture;

    portfolio = [];
    cycles = [];
    incorrect = false;

    HeapPriorityQueue pq = HeapPriorityQueue((t1, t2) {
      return t1.rate > t2.rate ? 1 : -1;
    });

    int b = 0, s = 0;

    while (s < sellLogs.length && b < buyLogs.length) {
      if (sellLogs[s].date.isBefore(buyLogs[b].date)) {
        var cycle =
            TradeCycle(sellLogs[s].date, sellLogs[s].qty, sellLogs[s].rate);
        while (cycle.netQty < 0 && pq.isNotEmpty) {
          var buyLog = pq.removeFirst();
          var remaining = cycle.addBuyLog(buyLog.qty, buyLog.rate);
          if (remaining != 0)
            pq.add(TradeLog(
              buyLog.date,
              buyLog.id,
              buyLog.code,
              buyLog.exchange,
              true,
              remaining,
              buyLog.rate,
            ));
        }
        if (pq.isEmpty && cycle.netQty < 0) {
          incorrect = true;
          return this;
        }
        cycles.add(cycle);
        s++;
      } else {
        pq.add(buyLogs[b++]);
      }
    }

    while (s < sellLogs.length) {
      var cycle =
          TradeCycle(sellLogs[s].date, sellLogs[s].qty, sellLogs[s].rate);
      while (cycle.netQty < 0 && pq.isNotEmpty) {
        var buyLog = pq.removeFirst();
        var remaining = cycle.addBuyLog(buyLog.qty, buyLog.rate);
        if (remaining != 0)
          pq.add(TradeLog(
            buyLog.date,
            buyLog.id,
            buyLog.code,
            buyLog.exchange,
            true,
            remaining,
            buyLog.rate,
          ));
      }
      if (pq.isEmpty && cycle.netQty < 0) {
        incorrect = true;
        return this;
      }
      cycles.add(cycle);
      s++;
    }

    while (b < buyLogs.length) {
      pq.add(buyLogs[b++]);
    }

    while (pq.isNotEmpty) {
      portfolio.add(pq.removeFirst());
    }

    return this;
  }

  Future<TradeSummary> _oldestFirst() async {
    var buyLogs = await _buyLogsFuture;
    var sellLogs = await _sellLogsFuture;

    portfolio = [];
    cycles = [];

    int b = 0, s = 0;
    while (s < sellLogs.length) {
      var cycle =
          TradeCycle(sellLogs[s].date, sellLogs[s].qty, sellLogs[s].rate);
      while (cycle.netQty < 0) {
        if (b >= buyLogs.length || sellLogs[s].date.isBefore(buyLogs[b].date)) {
          incorrect = true;
          return this;
        }
        var remaining = cycle.addBuyLog(buyLogs[b].qty, buyLogs[b].rate);
        if (remaining != 0) {
          buyLogs[b].qty = remaining;
        } else {
          buyLogs[b].qty = 0;
          b++;
        }
      }
      cycles.add(cycle);
      s++;
    }

    portfolio = buyLogs.sublist(b);

    return this;
  }
}
