import 'package:flutter/material.dart';
import 'package:folio/models/trade/parsed_file_logs.dart';

import 'import_logs.dart';
import 'file_log_tile.dart';

class ShowValidLogs extends StatelessWidget {
  final List<FileLog> _validLogs;

  ShowValidLogs(this._validLogs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Importing Fields"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImportLogs(_validLogs)));
            },
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FileLogTile(_validLogs[index], isLogValid: true);
        },
        itemCount: _validLogs.length,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Total: ${_validLogs.length}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
