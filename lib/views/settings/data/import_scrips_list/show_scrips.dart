import 'package:flutter/material.dart';
import 'package:folio/views/settings/data/import_scrips_list/import_scrips.dart';
import 'package:folio/views/settings/data/import_scrips_list/parsed_scrips.dart';

class ShowScrips extends StatelessWidget {
  final ParsedScripsList _scripsList;

  ShowScrips(this._scripsList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Importing Scrips for ${_scripsList.exchange}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImportScrips(_scripsList)));
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemBuilder: (context, index) {
              return ParsedScripTile(_scripsList.newScrips[index]);
            },
            itemCount: _scripsList.newScrips.length,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Total: ${_scripsList.newScrips.length}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}