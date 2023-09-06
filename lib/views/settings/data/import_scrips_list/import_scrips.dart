import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/settings/data/import_scrips_list/parsed_scrips.dart';

class ImportScrips extends StatefulWidget {
  final ParsedScripsList _scripsList;

  ImportScrips(this._scripsList);

  @override
  _ImportScripsState createState() => _ImportScripsState();
}

class _ImportScripsState extends State<ImportScrips> {
  late bool isImporting;
  String? _message;
  int? _current;
  int? _total;
  late Future<void> tradesFuture;

  @override
  void initState() {
    super.initState();
    isImporting = true;
    tradesFuture = addScrips();
  }

  Future<void> addScrips() async {
    await DatabaseActions.addScrips(widget._scripsList,
        onUpdate: updateProgress);

    setState(() {
      isImporting = false;
    });
  }

  void updateProgress({String? message, int? current, int? total}) {
    setState(() {
      _message = message;
      _current = current;
      _total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isImporting,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: isImporting ? Text("Importing") : Text("Imported"),
          centerTitle: true,
          automaticallyImplyLeading: !isImporting,
        ),
        body: FutureBuilder(
          future: tradesFuture,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_message ?? ""),
                    Text(_total == null ? "" : "${_current ?? "?"}/$_total"),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: _message == null
                          ? null
                          : LinearProgressIndicator(
                              value: _total != null &&
                                      _current != null &&
                                      _total != 0
                                  ? _current! / _total!
                                  : null,
                            ),
                    )
                  ],
                ),
              );
            }
            isImporting = false;
            if (snapshot.hasError) {
              return Center(
                child: Text(_message ?? "Error occurred during import of logs"),
              );
            }
            return Center(
              child: Text(
                "Scrips successfully imported",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            );
          },
        ),
      ),
    );
  }
}
