import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/models/stock/latest.dart';
import 'package:folio/models/trade/cycle.dart';
import 'package:folio/models/trade/summary.dart';
import 'package:folio/helpers/stock_repository.dart';
import 'package:folio/views/logs/log_tile.dart';
import 'package:folio/views/tracked/database_actions.dart';
import 'package:folio/views/tracked/details/cycle_tile.dart';
import 'package:folio/views/tracked/tracked_bottom_sheet.dart';
import 'package:folio/views/common/text_loading_indicator.dart';
import 'package:folio/views/settings/data/database_actions.dart' as imp;

class DetailsView extends StatefulWidget {
  final Stock stock;

  const DetailsView(this.stock);

  @override
  _DetailsViewState createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView>
    with TickerProviderStateMixin {
  Stock _stock;
  Latest _bseLatest;
  Latest _nseLatest;
  TradeCycle _computedCycle;
  TradeSummary _summary;
  Future<TradeSummary> _futureSummary;
  Future<List<TradeLog>> _futureLogs;

  StreamSubscription<Latest> _latestBSEStreamSub;
  StreamSubscription<Latest> _latestNSEStreamSub;
  TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _stock = widget.stock;

    if (_stock?.bseCode != null) {
      _latestBSEStreamSub =
          StockRepository.getPeriodicLatest(_stock?.bseCode, "BSE")
              .listen((value) {
        setState(() {
          _bseLatest = value;
        });
      });
    }

    if (_stock?.nseCode != null) {
      _latestNSEStreamSub =
          StockRepository.getPeriodicLatest(_stock?.nseCode, "NSE")
              .listen((value) {
        setState(() {
          _nseLatest = value;
        });
      });
    }

    _summary = TradeSummary(imp.DatabaseActions.getBuyLogs(_stock.id),
        imp.DatabaseActions.getSellLogs(_stock.id));

    _futureSummary = _summary.calculateSummary(0);
    _futureLogs = DatabaseActions.getStockLogs(_stock.id);

    _tabController = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _latestBSEStreamSub?.cancel();
    _latestNSEStreamSub?.cancel();

    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Details"),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stock?.name == null
                          ? TextLoadingIndicator(
                              width: 200,
                              height: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .fontSize)
                          : Flexible(
                              child: Text(
                                _stock?.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    _stock?.bseCode != null
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "BSE - " + _stock?.bseCode,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.edit,
                                    size: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontSize +
                                        3,
                                  ),
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => EditCodeDialog(
                                          _stock?.bseCode,
                                          "BSE",
                                          updateBSECode),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: 0,
                          ),
                    _stock?.nseCode != null
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "NSE - " + _stock?.nseCode,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.edit,
                                    size: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontSize +
                                        3,
                                  ),
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => EditCodeDialog(
                                          _stock?.nseCode,
                                          "NSE",
                                          updateNSECode),
                                    );
                                  },
                                )
                              ],
                            ),
                          )
                        : Container(
                            width: 0,
                          ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    _stock?.bseCode != null
                        ? MapTile(
                            name: "BSE PRICE",
                            value:
                                _bseLatest?.value?.toStringAsFixed(2) ?? "...",
                          )
                        : Container(
                            width: 0,
                          ),
                    _stock?.nseCode != null
                        ? MapTile(
                            name: "NSE PRICE",
                            value:
                                _nseLatest?.value?.toStringAsFixed(2) ?? "...",
                          )
                        : Container(
                            width: 0,
                          ),
                    MapTile(
                      name: "QTY",
                      value: _stock?.qty?.toString() ?? "N/A",
                    ),
                    MapTile(
                      name: "ESR",
                      value: _stock?.esr?.toStringAsFixed(2) ?? "N/A",
                    ),
                    MapTile(
                      name: "MSR",
                      value: _stock?.msr?.toStringAsFixed(2) ?? "N/A",
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: [
                        Tab(
                          child: Text("CALCULATE NET"),
                        ),
                        Tab(
                          child: Text("REMAINING"),
                        ),
                        Tab(
                          child: Text("CYCLES"),
                        ),
                        Tab(
                          child: Text("LOGS"),
                        ),
                      ],
                      indicatorColor: Theme.of(context).accentColor,
                      labelColor: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            color: Theme.of(context).accentColor,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder(
                  future: _futureSummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.hasError || snapshot.data.incorrect) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "Sorry there is some inconsistency in the logs",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                            key: _formKey,
                            child: Card(
                              color: Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Qty",
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          helperText: "Sell Qty"),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                      ],
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Required';
                                        } else if (int.parse(value) >
                                            _stock.qty) {
                                          return 'Too High!';
                                        }
                                        return null;
                                      },
                                      controller: _qtyController,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Rate",
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          helperText: "Sell Rate"),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
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
                                    Row(
                                      children: [
                                        Spacer(),
                                        FlatButton(
                                          child: Text("Calculate"),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              int qty = int.parse(
                                                  _qtyController.text);
                                              double rate =
                                                  _rateController.text.isEmpty
                                                      ? _stock?.lastValue
                                                      : double.parse(
                                                          _rateController.text);
                                              var cycle = _summary.computeCycle(
                                                  qty, rate);
                                              setState(() {
                                                _computedCycle = cycle;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _computedCycle == null
                              ? Container()
                              : CycleTile(_computedCycle),
                        ],
                      ),
                    );
                  },
                ),
                FutureBuilder(
                  future: _futureSummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.hasError || snapshot.data.incorrect) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "Sorry there is some inconsistency in the logs",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (_summary.portfolio.length == 0) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "No stocks remaining",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return LogTile(_summary.portfolio[index]);
                      },
                      itemCount: _summary.portfolio.length,
                    );
                  },
                ),
                FutureBuilder(
                  future: _futureSummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.hasError || snapshot.data.incorrect) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "Sorry there is some inconsistency in the logs",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (_summary.cycles.length == 0) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "No stocks sold",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CycleTile(_summary.cycles[index]);
                      },
                      itemCount: _summary.cycles.length,
                    );
                  },
                ),
                FutureBuilder(
                  future: _futureLogs,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "An error occurred",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.data.length == 0) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                "No logs imported",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return LogTile(snapshot.data[index]);
                      },
                      itemCount: snapshot.data.length,
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateBSECode(String code) {
    _stock.bseCode = code;
  }

  void updateNSECode(String code) {
    _stock.nseCode = code;
  }
}

class EditCodeDialog extends StatefulWidget {
  final String code;
  final String exchange;
  final Function(String) updateFn;

  const EditCodeDialog(this.code, this.exchange, this.updateFn);

  @override
  _EditCodeDialogState createState() => _EditCodeDialogState();
}

class _EditCodeDialogState extends State<EditCodeDialog> {
  TextEditingController _codeCtl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeCtl = TextEditingController();
  }

  @override
  void dispose() {
    _codeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Edit Code",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: widget.exchange + " code",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    helperText: widget.exchange + " code",
                  ),
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.text,
                  controller: _codeCtl,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Text("Apply"),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          if (widget.code != _codeCtl.text) {
                            await DatabaseActions.updateCode(
                              widget.code,
                              widget.exchange,
                              _codeCtl.text,
                            ).then((value) {
                              widget.updateFn(_codeCtl.text);
                              Navigator.pop(context);
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
