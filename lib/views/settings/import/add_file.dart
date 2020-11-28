import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:folio/models/database/trade_log.dart';
import 'package:folio/views/logs/log_tile.dart';
import 'package:folio/views/settings/import/database_actions.dart';

class AddFile extends StatefulWidget {
  final List<TradeLog> logs;

  AddFile(this.logs);

  @override
  _AddFileState createState() => _AddFileState();
}

class _AddFileState extends State<AddFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Add File"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              try {
                await DatabaseActions.addTradeLogs(widget.logs);
                Navigator.pop(context);
              } catch (e) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Couldn't add!"),
                      actions: [
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return LogTile(widget.logs[index]);
        },
        itemCount: widget.logs.length,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Total: ${widget.logs.length}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}
