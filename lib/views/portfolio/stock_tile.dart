import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folio/assets/folio_icons.dart';
import 'package:folio/contracts/stock_tile_contract.dart';
import 'package:folio/views/portfolio/database_access.dart';
import 'package:folio/views/portfolio/info_widgets.dart';
import 'package:folio/views/portfolio/trades/trades.dart';
import 'package:folio/models/stocks/current_stock_data.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/presenters/stock_data_presenter.dart';

class StockTile extends StatefulWidget {
  const StockTile({
    Key key,
    @required this.stockData,
    @required this.pinned,
    this.expand = false,
  })  : assert(stockData != null),
        assert(pinned != null),
        assert(expand != null),
        super(key: key);

  final StockData stockData;
  final bool expand;
  final bool pinned;

  @override
  _StockTileState createState() => _StockTileState();
}

class _StockTileState extends State<StockTile> implements StockTileContract {
  StockData _stockData;
  bool _isExpanded;
  bool _isRefreshing;
  bool _isPinned;
  bool _isVisible;
  StockDataPresenter _stockDataPresenter;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expand;
    _isPinned = widget.pinned;
    _stockData = widget.stockData;
    _isRefreshing = true;
    _stockDataPresenter = StockDataPresenter(this, _stockData);
    _isVisible = true;
  }

  @override
  void dispose() {
    super.dispose();
    _stockDataPresenter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? Card(
            color: Theme.of(context).primaryColor,
            margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            child: Container(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  if (!_isExpanded) {
                    setState(() {
                      _isExpanded = true;
                    });
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return TradesRoute(_stockData);
                    }));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: _isExpanded ? expand() : collapse(),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(width: 2, color: Theme.of(context).dividerColor),
            ),
          )
        : Container();
  }

  Widget common() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _stockData.name ?? "—",
            style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20.0,
                fontWeight: FontWeight.values[5]),
          ),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _stockData?.lastValue?.toStringAsFixed(2) ?? "—",
                    style:
                        TextStyle(fontWeight: FontWeight.w100, fontSize: 20.0),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _stockData.percentChange != null
                            ? "${_stockData.percentChange}%"
                            : "/",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _stockData.change ?? "/",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _stockData.changeSign == 1
                              ? Colors.green
                              : (_stockData.changeSign == -1
                                  ? Colors.red
                                  : Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _stockData?.netPerStock?.toStringAsFixed(2) ?? "—",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: _stockData.netSign == 1
                            ? Colors.green
                            : _stockData.netSign == -1
                                ? Colors.red
                                : Theme.of(context).accentColor),
                  ),
                  Text(
                    _stockData.percentNet != null
                        ? "${_stockData.percentNet}%"
                        : "/",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "price",
                style: TextStyle(
                  fontFamily: 'CarroisGothic',
                  fontSize: 13.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _stockData.netSign == 1
                    ? "profit"
                    : _stockData.netSign == -1
                        ? "loss"
                        : "profit / loss",
                style: TextStyle(
                  fontFamily: 'CarroisGothic',
                  fontSize: 13.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
        ],
      )
    ]);
  }

  Widget collapse() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _stockData.exchange,
              style: TextStyle(
                  fontSize: 12.0, color: Theme.of(context).dividerColor),
            ),
            Text(
              "",
              style: TextStyle(
                  fontSize: 12.0, color: Theme.of(context).dividerColor),
            )
          ],
        ),
      ),
      common(),
    ]);
  }

  Widget expand() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _stockData.exchange + " - " + _stockData.code,
              style: TextStyle(
                  fontSize: 12.0, color: Theme.of(context).dividerColor),
            ),
            Text(
              _stockData.lastUpdated ?? "—",
              style: TextStyle(
                  fontSize: 12.0, color: Theme.of(context).dividerColor),
            )
          ],
        ),
      ),
      common(),
      Padding(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.1,
            25.0, MediaQuery.of(context).size.width * 0.1, 0.0),
        child: InfoGroup(
          heading: "Owned",
          info: [
            InfoRow(
              title: "Quantity",
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                margin: EdgeInsets.symmetric(vertical: 2),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  _stockData.qty?.toString() ?? "—",
                ),
              ),
            ),
            InfoRow(
              title: "Min Sell Rate",
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  _stockData.msr?.toStringAsFixed(2) ?? "—",
                  style: TextStyle(
                    color: _stockData?.lastValue == null ||
                            _stockData?.msr == null ||
                            _stockData?.msr == _stockData?.lastValue
                        ? Theme.of(context).accentColor
                        : _stockData.lastValue > _stockData.msr
                            ? Colors.green
                            : Colors.red,
                    fontWeight: _stockData?.msr == null ? FontWeight.normal : FontWeight.w300,
                  ),
                ),
              ),
            ),
            InfoRow(
              title: "Estimated Sell Rate",
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                                color: _stockData?.esr == null
                                    ? Colors.transparent
                                    : Theme.of(context).accentColor),
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  _stockData.esr?.toStringAsFixed(2) ?? "—",
                  style: TextStyle(
                    color: _stockData?.lastValue == null ||
                            _stockData?.esr == null ||
                            _stockData?.esr == _stockData?.lastValue
                        ? Theme.of(context).accentColor
                        : _stockData.lastValue > _stockData.esr
                            ? Colors.green
                            : Colors.red,
                    fontWeight: _stockData?.esr == null ? FontWeight.normal : FontWeight.w800,
                  ),
                ),
              ),
            ),
            InfoRow(
              title: "Overall Net",
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: (_stockData?.netSign ?? 0) == 0
                        ? Colors.transparent
                        : _stockData?.netSign == 1
                            ? Colors.green
                            : Colors.red),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(_stockData.netAmount != null
                    ? _stockData.netAmount.toStringAsFixed(2)
                    : "—"),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 27.0,
              width: 50.0,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.compress),
                iconSize: 25.0,
                splashRadius: 25.0,
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                tooltip: "Collapse",
              ),
            ),
            SizedBox(
              height: 27.0,
              width: 50.0,
              child: _isRefreshing
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(Icons.refresh),
                      disabledColor: Colors.grey,
                      iconSize: 25.0,
                      splashRadius: 25.0,
                      onPressed: _refresh, //TODO: set function
                      tooltip: "Refresh",
                    ),
            ),
            SizedBox(
              height: 27.0,
              width: 50.0,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(_isPinned ? Folio.unpin : Folio.pin),
                iconSize: 25.0,
                splashRadius: 25.0,
                onPressed: _onPinPressed,
                tooltip: _isPinned ? "Unpin" : "Pin",
              ),
            ),
            SizedBox(
              height: 27.0,
              width: 50.0,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.visibility_off),
                iconSize: 25.0,
                splashRadius: 25.0,
                onPressed: () {
                  setState(() {
                    if (_stockData?.qty != null || _stockData?.qty != 0) return;
                    // TODO: add Db function
                    _isVisible = false;
                  });
                },
                tooltip: "Untrack",
              ),
            ),
          ],
        ),
      )
    ]);
  }

  void _onPinPressed() async {
    bool res = await DatabaseAccess.updatePinned(
        _stockData.code, _stockData.exchange, !_isPinned);
    if (res) {
      setState(() {
        _isPinned = !_isPinned;
      });
    }
  }

  void _refresh() {
    setState(() {
      _isRefreshing = true;
    });
    _stockDataPresenter.refreshNow();
  }

  @override
  void currentStockDataUpdate(CurrentStockData newData) {
    setState(() {
      _stockData.current = newData;
      _isRefreshing = false;
    });
  }
}
