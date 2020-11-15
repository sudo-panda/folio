import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/views/portfolio/database_access.dart';
import 'package:folio/views/settings/settings.dart';
import 'package:folio/views/portfolio/portfolio_list.dart';

class PortfolioScrollView extends StatefulWidget {
  @override
  _PortfolioScrollViewState createState() => _PortfolioScrollViewState();
}

class _PortfolioScrollViewState extends State<PortfolioScrollView> {
  Future<List<StockData>> _pinnedStockFuture;
  Future<List<StockData>> _unpinnedStockFuture;

  Future<bool> hasData() async {
    if ((await _pinnedStockFuture).length == 0 &&
        (await _unpinnedStockFuture).length == 0) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    _pinnedStockFuture = DatabaseAccess.getPinnedStockData();
    _unpinnedStockFuture = DatabaseAccess.getUnpinnedStockData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          actions: [
            IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.settings),
              iconSize: 25.0,
              splashRadius: 18.0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SettingsRoute();
                })).then((value) {
                  setState(() {
                    _pinnedStockFuture = DatabaseAccess.getPinnedStockData();
                    _unpinnedStockFuture =
                        DatabaseAccess.getUnpinnedStockData();
                  });
                });
              },
            ),
          ],
          expandedHeight: MediaQuery.of(context).size.height * 0.30,
          floating: false,
          pinned: true,
          snap: false,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 0, 0, 0.5),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: [0.0, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(12.5),
                child: Text(
                  'Portfolio',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        PortfolioList(
          future: _pinnedStockFuture,
          pinned: true,
        ),
        FutureBuilder(
          future: hasData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none &&
                    snapshot.hasData == null ||
                snapshot.data == null) {
              return SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.15),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
              );
            } else if (!snapshot.data) {
              return SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Center(
                    child: Text(
                      "No Data",
                      style: TextStyle(
                          fontFamily: 'CarroisGothic',
                          fontSize: 30,
                          fontWeight: FontWeight.w100,
                          color: Color.fromARGB(200, 128, 128, 128)),
                    ),
                  ),
                ),
              );
            } else {
              return SliverList(
                delegate: SliverChildListDelegate([]),
              );
            }
          },
        ),
        PortfolioList(
          future: _unpinnedStockFuture,
          pinned: false,
        )
      ],
    );
  }
}

class PortfolioRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PortfolioScrollView(),
    );
  }
}
