import 'package:flutter/material.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/trades/trades_tile.dart';
import 'package:folio/views/settings/data/add_trade_log.dart';

class TradesView extends StatefulWidget {
  @override
  _TradesViewState createState() => _TradesViewState();
}

class _TradesViewState extends State<TradesView> {
  late Future<List<TradeLog>> _getLogsFuture;

  @override
  void initState() {
    super.initState();
    _getLogsFuture = DatabaseActions.getAllTrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: new Icon(Icons.clear_all_outlined),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: FolioDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Trades",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.background,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            shape: const CircleBorder()),
                        child: Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AddTradeLogRoute();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _getLogsFuture,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Container(),
                );
              }
              if (snapshot.hasData && (snapshot.data?.length ?? 0) == 0) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No logs imported",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return LogTile(snapshot.data[index]);
                  },
                  childCount: snapshot.data.length,
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(1),
    );
  }
}
