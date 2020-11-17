import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/models/trades/trade_cycle.dart';
import 'package:folio/models/trades/trade_log.dart';
import 'package:folio/models/trades/trade_summary.dart';
import 'package:folio/views/portfolio/info_widgets.dart';
import 'package:folio/views/portfolio/trades/database_actions.dart';
import 'package:intl/intl.dart';

class TradesRoute extends StatefulWidget {
  final StockData stockData;

  const TradesRoute(this.stockData);

  @override
  _TradesRouteState createState() => _TradesRouteState();
}

class _TradesRouteState extends State<TradesRoute> {
  TradeSummary _summary;
  int _ordering;
  double _value;
  StockData _stockData;
  TradeCycle _computedCycle;
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _exchangeController = TextEditingController();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stockData = widget.stockData;
    _summary = TradeSummary(
        DatabaseActions.getBuyLogs(_stockData.code, _stockData.exchange),
        DatabaseActions.getSellLogs(_stockData.code, _stockData.exchange));
    _ordering = 0;
    _value = _stockData?.lastValue;
    _computedCycle = null;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _exchangeController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            tooltip: "Edit",
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Edit Details",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Empty fields remain unchanged",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Exchange",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                                hintText: _stockData.exchange,
                                helperText: "Current: " + _stockData.exchange,
                              ),
                              controller: _exchangeController,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Code",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                                hintText: _stockData.code,
                                helperText: "Current: " + _stockData.code,
                              ),
                              controller: _codeController,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Name",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                                hintText: _stockData?.name ?? "",
                                helperText:
                                    "Current: " + (_stockData?.name ?? ""),
                              ),
                              controller: _nameController,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlineButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text("Submit"),
                                  onPressed: () async {
                                    if (_exchangeController.text
                                            .trim()
                                            .isEmpty &&
                                        _codeController.text.trim().isEmpty &&
                                        _nameController.text.trim().isEmpty) {
                                      Navigator.pop(context);
                                    } else if (_exchangeController.text
                                            .trim()
                                            .isEmpty &&
                                        _codeController.text.trim().isEmpty) {
                                      bool res = await DatabaseActions
                                          .updatePortfolioName(
                                        _stockData.code,
                                        _stockData.exchange,
                                        _nameController.text.trim(),
                                      );
                                      if (res) {
                                        _stockData.name =
                                            _nameController.text.trim();
                                      }
                                      Navigator.pop(context);
                                    } else {
                                      String code =
                                          _codeController.text.trim().isNotEmpty
                                              ? _codeController.text.trim()
                                              : _stockData.code;
                                      String exchange = _exchangeController.text
                                              .trim()
                                              .isNotEmpty
                                          ? _exchangeController.text.trim()
                                          : _stockData.exchange;

                                      bool res = await DatabaseActions
                                          .updateTradeLogCodeExchange(
                                        _stockData.code,
                                        _stockData.exchange,
                                        code,
                                        exchange,
                                      );

                                      if (res) {
                                        res = await DatabaseActions
                                            .updatePortfolioCodeExch(
                                          _stockData.code,
                                          _stockData.exchange,
                                          code,
                                          exchange,
                                        );
                                        

                                        if (res &&
                                            _nameController.text
                                                .trim()
                                                .isNotEmpty) {
                                          res = await DatabaseActions
                                              .updatePortfolioName(
                                            code,
                                            exchange,
                                            _nameController.text.trim(),
                                          );
                                        }
                                      }

                                      Navigator.pop(context);
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    _stockData.exchange,
                    style: TextStyle(
                        fontSize: 15.0, color: Theme.of(context).dividerColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    _stockData.code,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _stockData.name ?? "—",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20.0,
                      fontWeight: FontWeight.values[5],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.1,
                      25.0,
                      MediaQuery.of(context).size.width * 0.1,
                      0.0),
                  child: Column(
                    children: [
                      InfoRow(
                        title: "Current Rate",
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            _value?.toStringAsFixed(2) ?? "—",
                            style: TextStyle(
                                fontSize: 18,
                                color: _stockData.changeSign == 1
                                    ? Colors.green
                                    : (_stockData.changeSign == -1
                                        ? Colors.red
                                        : Theme.of(context).accentColor)),
                          ),
                        ),
                      ),
                      InfoRow(
                        title: "Quantity",
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            _stockData.msr?.toStringAsFixed(2) ?? "—",
                            style: TextStyle(
                                color: _value == null ||
                                        _stockData?.msr == null ||
                                        _stockData?.msr == _value
                                    ? Theme.of(context).accentColor
                                    : _stockData.lastValue > _stockData.msr
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: _stockData?.msr == null
                                    ? FontWeight.normal
                                    : FontWeight.w300),
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
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            _stockData.esr?.toStringAsFixed(2) ?? "—",
                            style: TextStyle(
                                color: _value == null ||
                                        _stockData?.esr == null ||
                                        _stockData?.esr == _value
                                    ? Theme.of(context).accentColor
                                    : _stockData.lastValue > _stockData.esr
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: _stockData?.esr == null
                                    ? FontWeight.normal
                                    : FontWeight.w800),
                          ),
                        ),
                      ),
                      InfoRow(
                        title: "Net / Stock",
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: (_stockData?.netSign ?? 0) == 0
                                  ? Colors.transparent
                                  : _stockData?.netSign == 1
                                      ? Colors.green
                                      : Colors.red),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(_stockData.netPerStock != null
                              ? _stockData.netPerStock.toStringAsFixed(2)
                              : "—"),
                        ),
                      ),
                      InfoRow(
                        title: "Net",
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: (_stockData?.netSign ?? 0) == 0
                                  ? Colors.transparent
                                  : _stockData?.netSign == 1
                                      ? Colors.green
                                      : Colors.red),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(_stockData.netAmount != null
                              ? _stockData.netAmount.toStringAsFixed(2)
                              : "—"),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: _summary.calculateSummary(_ordering),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.incorrect) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Center(
                            child: Text(
                              "Sorry there is some\n"
                              "inconsistency in the logs",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TableCard(
                                title: "Calculate Net",
                                header: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Form(
                                    key: _formKey,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                labelText: "Qty",
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                helperText: "Sell Qty"),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                            ],
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Required';
                                              } else if (int.parse(value) >
                                                  _stockData.qty) {
                                                return 'Too High!';
                                              }
                                              return null;
                                            },
                                            controller: _qtyController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          height: 50,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "X",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 100,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Rate",
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 15),
                                                  helperText: "Sell Rate"),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              validator: (value) {
                                                if (value.isEmpty ||
                                                    RegExp(r"^[0-9]*(\.[0-9][0-9]?)?$")
                                                        .hasMatch(value)) {
                                                  return null;
                                                }
                                                return "Enter valid rate";
                                              },
                                              controller: _rateController,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          height: 50,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: RaisedButton(
                                                onPressed: () {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    int qty = int.parse(
                                                        _qtyController.text);
                                                    double rate =
                                                        _rateController
                                                                .text.isEmpty
                                                            ? _stockData
                                                                ?.lastValue
                                                            : double.parse(
                                                                _rateController
                                                                    .text);
                                                    var cycle =
                                                        _summary.computeCycle(
                                                            qty, rate);
                                                    setState(() {
                                                      _computedCycle = cycle;
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  "=",
                                                  style:
                                                      TextStyle(fontSize: 30),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child: _computedCycle == null
                                    ? Container()
                                    : CycleTile(_computedCycle),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              TableCard(
                                title: "Portfolio",
                                header: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 30,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Date",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Qty",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                "@",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Total Buy\nRate",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "Minimum\nSell Rate",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  child: snapshot.data.portfolio.length == 0
                                      ? Center(
                                          child: Text(
                                            "No stock left",
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              snapshot.data.portfolio.length,
                                          itemBuilder: (context, index) {
                                            return PortfolioTile(
                                                snapshot.data.portfolio[index],
                                                _value);
                                          },
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              TableCard(
                                title: "Cycles",
                                header: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 13, 8, 13),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DATE",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Sell Qty",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.red),
                                                    ),
                                                    Text(
                                                      " x",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "Sell Rate",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                            child: Text(
                                              "—",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Buy Qty",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.green),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                      child: Text(
                                                        " x",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w100,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "Buy Rate",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                            child: Text(
                                              "—",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Brokerage",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.yellow),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Text(""),
                                          ),
                                          Text(
                                            "=",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w100,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Net",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  child: snapshot.data.cycles.length == 0
                                      ? Center(
                                          child: Text(
                                            "Stocks haven't been sold yet",
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              snapshot.data.cycles.length,
                                          itemBuilder: (context, index) {
                                            return CycleTile(
                                                snapshot.data.cycles[index]);
                                          },
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CycleTile extends StatelessWidget {
  final TradeCycle cycle;
  final DateFormat dateFormatter = DateFormat('dd MMM y');

  CycleTile(
    this.cycle,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 13.0, 8.0, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatter.format(cycle.date),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).dividerColor,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            cycle.sellQty.toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          ),
                          Text(
                            " x",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        cycle.sellRate.toStringAsFixed(2),
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "—",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.from(
                      cycle.invoices.map(
                        (element) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  element.qty.toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.green),
                                ),
                                Text(
                                  " x",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              element.rate.toStringAsFixed(2),
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.green),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    "—",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    cycle.brokerage.toStringAsFixed(2),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13, color: Colors.yellow),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(""),
                ),
                Text(
                  "=",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: cycle.net > 0
                              ? Colors.green
                              : cycle.net < 0
                                  ? Colors.red
                                  : Colors.transparent,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text(
                          cycle.net.abs().toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioTile extends StatelessWidget {
  final TradeLog trade;
  final DateFormat dateFormatter = DateFormat('dd MMM');
  final value;
  final brokerage = 0.02;

  PortfolioTile(this.trade, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      dateFormatter.format(trade.date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    Text(
                      trade.date.year.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      trade.qty.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      "@",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w100),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (trade.rate * (1.0 + brokerage)).toStringAsFixed(2),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (trade.rate * (1.0 + brokerage * 2.1)).toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: value == null || value == (trade.rate * 1.042)
                            ? Theme.of(context).accentColor
                            : value > (trade.rate * 1.042)
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableCard extends StatelessWidget {
  final String title;
  final Widget header;
  final Widget child;

  TableCard(
      {Key key,
      @required String title,
      @required Widget header,
      @required Widget child})
      : title = title,
        header = header,
        child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: SizedBox(
              width: double.maxFinite,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xAA888888),
                    const Color(0x00000000),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(),
            child: header,
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0x55888888),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
