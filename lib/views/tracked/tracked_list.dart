import 'package:flutter/material.dart';
import 'package:folio/models/stock/stock.dart';
import 'package:folio/views/tracked/tracked_tile.dart';

class TrackedList extends StatefulWidget {
  TrackedList({Key key, @required this.future}) : super(key: key);

  final Future<List<Stock>> future;

  @override
  _TrackedListState createState() => _TrackedListState();
}

class _TrackedListState extends State<TrackedList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || snapshot.hasError ||
            (snapshot.data?.length ?? 0) == 0 ) {
          return SliverToBoxAdapter(
            child: Container(),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return TrackedTile(snapshot.data[index]);
            },
            childCount: snapshot.data.length,
          ),
        );
      },
    );
  }
}
