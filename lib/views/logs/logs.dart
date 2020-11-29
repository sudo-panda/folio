import 'package:flutter/material.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/views/logs/database_actions.dart';
import 'package:folio/views/logs/log_tile.dart';
import 'package:folio/views/settings/data/add_trade_log.dart';

class LogsView extends StatefulWidget {
  @override
  _LogsViewState createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  Future<List<TradeLog>> _getLogsFuture;

  @override
  void initState() {
    super.initState();
    _getLogsFuture = DatabaseActions.getAllLogs();
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
                        "Logs",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      RaisedButton(
                        shape: CircleBorder(),
                        child: Icon(Icons.add),
                        color: Theme.of(context).accentColor,
                        textColor: Theme.of(context).backgroundColor,
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
            builder: (context, snapshot) {
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
                      style: Theme.of(context).textTheme.headline4,
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
