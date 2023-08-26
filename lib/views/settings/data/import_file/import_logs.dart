import 'package:flutter/material.dart';
import 'package:folio/helpers/database_actions.dart';
import 'package:folio/models/trade/parsed_file_logs.dart';

import '../../../../models/database/trade_log.dart';
import '../../../trades/trades_tile.dart';

class ImportLogs extends StatefulWidget {
  final List<FileLog> _logs;

  ImportLogs(this._logs);

  @override
  _ImportLogsState createState() => _ImportLogsState();
}

class _ImportLogsState extends State<ImportLogs> {
  late bool isImporting;
  String? _message;
  int? _current;
  int? _total;
  late Future<List<TradeLog>> tradesFuture;

  @override
  void initState() {
    super.initState();
    isImporting = true;
    tradesFuture = addFileLogs();
  }

  Future<List<TradeLog>> addFileLogs() async {
    var trades = await DatabaseActions.addFileLogs(widget._logs,
        onUpdate: updateProgress);

    setState(() {
      isImporting = false;
    });

    return trades;
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
            if (snapshot.hasData && (snapshot.data?.length ?? 0) == 0) {
              return Center(
                child: Text(
                  "No logs imported",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return LogTile(snapshot.data[index]);
              },
              itemCount: snapshot.data.length,
            );
          },
        ),
      ),
    );
  }
}
