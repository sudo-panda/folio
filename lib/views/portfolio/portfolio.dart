import 'package:flutter/material.dart';
import 'package:folio/models/database/portfolio.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/portfolio/portfolio_tile.dart';

class PortfolioView extends StatefulWidget {
  @override
  _PortfolioViewState createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  late Future<List<Portfolio>> _getPortfolioFuture;

  @override
  void initState() {
    super.initState();
    _getPortfolioFuture = DatabaseActions.getAllPortfolioLogs();
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
                        "Portfolio",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.background,
                          shape: const CircleBorder(),
                        ),
                        child: Icon(Icons.sync),
                        onPressed: () {
                          // TODO: Call updateAllPortfolioFigures after a warning
                          DatabaseActions.updateAllPortfolioFigures();
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _getPortfolioFuture,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SliverToBoxAdapter(
                  child: Container(),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "Some error occurred",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              if (snapshot.hasData && (snapshot.data?.length ?? 0) == 0) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No stocks in your portfolio",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return PortfolioTile(snapshot.data[index]);
                  },
                  childCount: snapshot.data.length,
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(2),
    );
  }
}
