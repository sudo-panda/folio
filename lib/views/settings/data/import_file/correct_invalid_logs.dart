import 'package:flutter/material.dart';
import 'package:folio/models/trade/parsed_file_logs.dart';
import 'package:folio/views/settings/data/import_file/show_valid_logs.dart';

import 'file_log_tile.dart';

class CorrectInvalidLogs extends StatefulWidget {
  final ParsedFileLogs _logs;

  CorrectInvalidLogs(this._logs);

  @override
  _CorrectInvalidLogsState createState() => _CorrectInvalidLogsState();
}

class _CorrectInvalidLogsState extends State<CorrectInvalidLogs> {
  late List<FileLog> correctedLogs;
  late List<bool> isCorrected;

  @override
  void initState() {
    super.initState();
    correctedLogs = widget._logs.invalidLogs;
    isCorrected =
        List.filled(widget._logs.invalidLogs.length, false, growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Correct Missing Fields"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (isCorrected.contains(false)) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Please correct all logs"),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () async => Navigator.pop(context),
                        )
                      ],
                    );
                  },
                );
                return;
              } else {
                widget._logs.validLogs.addAll(correctedLogs);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowValidLogs(widget._logs.validLogs),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FileLogTile(
            widget._logs.invalidLogs[index],
            index: index,
            updateLog: updateLog,
          );
        },
        itemCount: widget._logs.invalidLogs.length,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Total: ${widget._logs.validLogs.length + widget._logs.invalidLogs.length}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }

  void updateLog(int index, FileLog log) {
    correctedLogs[index] = log;

    if (log.exchange != null &&
        log.bought != null &&
        log.date != null &&
        log.code != null)
      isCorrected[index] = true;
    else
      isCorrected[index] = false;
  }
}
