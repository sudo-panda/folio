import 'package:flutter/material.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/views/settings/data/track_stock_dialog.dart';
import 'package:folio/views/tracked/tracked_list.dart';

class TrackedView extends StatefulWidget {
  @override
  _TrackedViewState createState() => _TrackedViewState();
}

class _TrackedViewState extends State<TrackedView> {
  late Future<List<Stock>?> _pinnedStockFuture;
  late Future<List<Stock>?> _unpinnedStockFuture;

  Future<bool> hasData() async {
    if (((await _pinnedStockFuture)?.length ?? 0) == 0 &&
        ((await _unpinnedStockFuture)?.length ?? 0) == 0) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    _pinnedStockFuture = DatabaseActions.getPinnedStocks();
    _unpinnedStockFuture = DatabaseActions.getUnpinnedStocks();
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
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Tracked",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.background,
                            shape: const CircleBorder(),
                        ),
                        child: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => TrackStockDialog(),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          TrackedList(
            future: _pinnedStockFuture,
          ),
          FutureBuilder(
            future: hasData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    ),
                  ),
                );
              } else if (!snapshot.hasData) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No stocks tracked",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(
                      height: 20,
                    )
                  ]),
                );
              }
            },
          ),
          TrackedList(
            future: _unpinnedStockFuture,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(0),
    );
  }
}
