import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/models/trades/trade_summary.dart';
import 'package:folio/views/portfolio/trades/database_access.dart';
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
  final DateFormat _dayMonth = DateFormat('dd MMM');

  @override
  void initState() {
    super.initState();
    _summary = TradeSummary(
        DatabaseAccess.getBuyLogs(
            widget.stockData.code, widget.stockData.exchange),
        DatabaseAccess.getSellLogs(
            widget.stockData.code, widget.stockData.exchange));
    _ordering = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: FutureBuilder(
              future: _summary.calculateSummary(_ordering),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.incorrect) {
                    return Center(
                      child: Text(
                        "Sorry there is some\ninconsistency in the logs",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Container(
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "PORTFOLIO",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.45,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 0),
                                      ),
                                      child: ListView.builder(
                                        itemCount:
                                            snapshot.data.portfolio.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF1A1A1A),
                                                    const Color(0xFF000000),
                                                  ],
                                                  begin: const FractionalOffset(
                                                      0.0, 0.0),
                                                  end: const FractionalOffset(
                                                      0.0, 1.0),
                                                  stops: [0.0, 1.0],
                                                  tileMode: TileMode.clamp),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      snapshot.data
                                                          .portfolio[index].qty
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text(
                                                      " @ ",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      snapshot.data
                                                          .portfolio[index].rate
                                                          .toStringAsFixed(2),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 60,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          _dayMonth.format(
                                                              snapshot
                                                                  .data
                                                                  .portfolio[
                                                                      index]
                                                                  .date),
                                                        ),
                                                        Text(snapshot
                                                            .data
                                                            .portfolio[index]
                                                            .date
                                                            .year
                                                            .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF55AA00),
                                    const Color(0xFF003355),
                                  ],
                                  begin: const FractionalOffset(0.0, 0.0),
                                  end: const FractionalOffset(0.0, 1.0),
                                  stops: [0.0, 0.3],
                                  tileMode: TileMode.clamp,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "CYCLES",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.45,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 0),
                                      ),
                                      child: snapshot.data.cycles.length == 0
                                          ? Center(
                                              child: Text(
                                                  "Stocks haven't been sold"))
                                          : ListView.builder(
                                              itemCount:
                                                  snapshot.data.cycles.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          const Color(
                                                              0xFF1A1A1A),
                                                          const Color(
                                                              0xFF000000),
                                                        ],
                                                        begin:
                                                            const FractionalOffset(
                                                                0.0, 0.0),
                                                        end:
                                                            const FractionalOffset(
                                                                0.0, 1.0),
                                                        stops: [0.0, 1.0],
                                                        tileMode:
                                                            TileMode.clamp),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 13),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 30,
                                                                    child: Text(
                                                                      snapshot
                                                                          .data
                                                                          .cycles[
                                                                              index]
                                                                          .sellQty
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                    child: Text(
                                                                      "x",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      snapshot
                                                                          .data
                                                                          .cycles[
                                                                              index]
                                                                          .sellRate
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                              child: Text(
                                                                "—",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                children: List<
                                                                        Widget>.from(
                                                                    snapshot
                                                                        .data
                                                                        .cycles[
                                                                            index]
                                                                        .invoices
                                                                        .map(
                                                                  (element) =>
                                                                      (Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            30,
                                                                        child:
                                                                            Text(
                                                                          element
                                                                              .qty
                                                                              .toString(),
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.green),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                        child:
                                                                            Text(
                                                                          "x",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(fontSize: 13),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(
                                                                            element.rate.toStringAsFixed(
                                                                                2),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style: TextStyle(fontSize: 15, color: Colors.green)),
                                                                      )
                                                                    ],
                                                                  )),
                                                                )),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                              child: Text(
                                                                "—",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                snapshot
                                                                    .data
                                                                    .cycles[
                                                                        index]
                                                                    .brokerage
                                                                    .toStringAsFixed(
                                                                        2),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .yellow),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                _dayMonth.format(snapshot
                                                                        .data
                                                                        .cycles[
                                                                            index]
                                                                        .date) +
                                                                    " " +
                                                                    snapshot
                                                                        .data
                                                                        .cycles[
                                                                            index]
                                                                        .date
                                                                        .year
                                                                        .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                            Text(
                                                              "=",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                snapshot
                                                                    .data
                                                                    .cycles[
                                                                        index]
                                                                    .net
                                                                    .toStringAsFixed(
                                                                        2),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w100),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0055AA),
                                    const Color(0xFF330055),
                                  ],
                                  begin: const FractionalOffset(0.0, 0.0),
                                  end: const FractionalOffset(0.0, 1.0),
                                  stops: [0.0, 0.3],
                                  tileMode: TileMode.clamp,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
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
          ),
        ),
      ),
    );
  }
}
