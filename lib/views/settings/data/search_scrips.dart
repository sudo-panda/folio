import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/models/database/scrip.dart';
import 'package:folio/views/settings/data/scrip_tile.dart';

class SearchSecuritiesRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchSecuritiesRouteState();
}

class _SearchSecuritiesRouteState extends State<SearchSecuritiesRoute> {
  final TextEditingController _searchController = TextEditingController();
  late String searchString;

  @override
  void initState() {
    super.initState();
    searchString = "";
  }

  Future<List<Scrip>> search(String str) async {
    if (str == "")
      return [];
    else
      return await DatabaseActions.getScripsLike(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: UnderlineInputBorder(),
          ),
          onChanged: (String value) {
            setState(() {
              searchString = value;
            });
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          FutureBuilder(
            future: search(searchString),
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
                      searchString == "" ? "" : "No Securities Found",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ScripTile(snapshot.data?[index],
                        refreshParent: refreshList);
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
      searchString = searchString;
    });
  }
}
