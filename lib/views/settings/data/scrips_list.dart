import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/models/database/scrip.dart';
import 'package:folio/views/settings/data/import_scrips_list/select_scrips_file.dart';
import 'package:folio/views/settings/data/scrip_tile.dart';

class ShowSecuritiesRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShowSecuritiesRouteState();
}

class _ShowSecuritiesRouteState extends State<ShowSecuritiesRoute> {
  late Future<List<Scrip>?> _scripsListFuture;

  @override
  void initState() {
    super.initState();
    _scripsListFuture = DatabaseActions.getAllScrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Securities"),
        actions: [
          IconButton(
            icon: Icon(Icons.plus_one),
            onPressed: () async {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ImportScrip),);
            },
          ),
          IconButton(
            icon: Icon(Icons.note_add_outlined),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImportScripsFileRoute()),
              );
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          FutureBuilder(
            future: _scripsListFuture,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error Occurred",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              if ((snapshot.data?.length ?? 0) == 0) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No Securities Found",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ScripTile(snapshot.data?[index], refreshParent: refreshList);
                  },
                  childCount: (snapshot.data?.length ?? 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void refreshList() {
    setState(() {
      _scripsListFuture = DatabaseActions.getAllScrips();
    });
  }
}