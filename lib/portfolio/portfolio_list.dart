import 'package:flutter/material.dart';
import 'package:folio/models/stocks/stock_data.dart';
import 'package:folio/portfolio/stock_tile.dart';
import 'package:folio/services/query/query_nse_api.dart';

class PortfolioList extends StatefulWidget {
  PortfolioList({Key key, @required this.future, @required this.pinned})
      : assert(pinned != null),
        super(key: key);

  final Future<List<StockData>> future;
  final bool pinned;

  @override
  _PortfolioListState createState() => _PortfolioListState();
}

class _PortfolioListState extends State<PortfolioList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
                snapshot.hasData == null ||
            snapshot.data == null ||
            snapshot.data.length == 0) {
          return SliverToBoxAdapter(
            child: Container(),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return StockTile(
                    stockData: snapshot.data[index], pinned: widget.pinned);
              },
              childCount: snapshot.data.length,
            ),
          );
        }
      },
    );
  }
}
