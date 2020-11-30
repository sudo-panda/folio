import 'package:flutter/material.dart';
import 'package:folio/models/database/portfolio.dart';
import 'package:folio/views/common/bottom_navbar.dart';
import 'package:folio/views/common/drawer.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/portfolio/portfolio_tile.dart';
import 'package:folio/views/settings/data/add_portfolio_dialog.dart';

class PortfolioView extends StatefulWidget {
  @override
  _PortfolioViewState createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  Future<List<Portfolio>> _getPortfolioFuture;

  @override
  void initState() {
    super.initState();
    _getPortfolioFuture = DatabaseActions.getAllPortfolios();
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
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      RaisedButton(
                        shape: CircleBorder(),
                        child: Icon(Icons.add),
                        color: Theme.of(context).accentColor,
                        textColor: Theme.of(context).backgroundColor,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddPortfolioDialog(),
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
            future: _getPortfolioFuture,
            builder: (context, snapshot) {
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
                      style: Theme.of(context).textTheme.headline4,
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
                      style: Theme.of(context).textTheme.headline4,
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
