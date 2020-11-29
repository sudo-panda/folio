import 'dart:developer';
import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:folio/views/settings/data/add_file.dart';
import 'package:folio/views/settings/data/add_portfolio_dialog.dart';
import 'package:folio/views/settings/data/add_trade_log.dart';
import 'package:folio/views/settings/data/database_actions.dart';
import 'package:folio/views/settings/data/track_stock_dialog.dart';

class ImportRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Data"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [
          SizedBox(
            width: 50.0,
            child: Icon(Icons.table_chart_outlined),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromWindowPadding(WindowPadding.zero, 1),
          child: ImportArea(),
        ),
      ),
    );
  }
}

class ImportArea extends StatefulWidget {
  @override
  _ImportAreaState createState() => _ImportAreaState();
}

class _ImportAreaState extends State<ImportArea> {
  bool _isButtonEnabled;

  @override
  void initState() {
    super.initState();
    _isButtonEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Import",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text("Import File"),
                  trailing: _isButtonEnabled
                      ? Icon(
                          Icons.folder_open_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        ),
                  onTap: _isButtonEnabled ? importLogs : null,
                ),
                ListTile(
                  title: Text("Track a stock"),
                  trailing: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: _isButtonEnabled
                      ? () async {
                          await showDialog(
                            context: context,
                            builder: (context) => TrackStockDialog(),
                          );
                        }
                      : null,
                ),
                ListTile(
                  title: Text("Add log"),
                  trailing: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: _isButtonEnabled
                      ? () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return AddTradeLogRoute();
                            }),
                          );
                        }
                      : null,
                ),
                ListTile(
                  title: Text("Add to portfolio"),
                  trailing: Icon(
                    Icons.link_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: _isButtonEnabled
                      ? () async {
                          await showDialog(
                            context: context,
                            builder: (context) => AddPortfolioDialog(),
                          );
                        }
                      : null,
                ),
                Divider(),
                Text(
                  "Export",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text("Export to CSV"),
                  trailing: Icon(
                    Icons.download_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: _isButtonEnabled ? exportLogs : null,
                ),
                Divider(),
                Text(
                  "Delete",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  title: Text("Delete Database"),
                  onTap: () async {
                    String result = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Careful!"),
                        content: Text(
                          "This will delete the database. Proceed only if you know what you are doing.",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        actions: [
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            color: Theme.of(context).buttonColor,
                            onPressed: () {
                              Navigator.pop(context, "");
                            },
                            child: Text("Delete"),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            color: Theme.of(context).buttonColor,
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    );
                    if (result == "") {
                      DatabaseActions.deleteDbThenInit();
                    }
                  },
                )
              ],
            ),
          ),
          Spacer(),
          FutureBuilder(
            future: DatabaseActions.getRecentDate(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.amberAccent),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                      ),
                      Expanded(
                        child: Text(
                          "Most recent entry is on: "
                          "${snapshot.data.day.toString()}-"
                          "${snapshot.data.month.toString()}-"
                          "${snapshot.data.year.toString()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  height: 100,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      "",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void importLogs() async {
    setState(() {
      _isButtonEnabled = false;
    });

    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      String file;
      try {
        file = File(result.files.first.path).readAsStringSync();
      } catch (e) {
        log("data.importLogs() => Error in reading file\n " + e.toString());
      }

      var logs;
      try {
        switch (result.files.first.extension) {
          case "csv":
            logs = await DatabaseActions.parseCSVFile(file);
            break;
          case "xls":
            logs = await DatabaseActions.parseSBIFile(file);
            break;
          default:
            setState(() {
              _isButtonEnabled = true;
            });
            return;
        }
      } catch (e) {
        log(e.toString());
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AddFile(logs);
        }),
      );
    }

    setState(() {
      _isButtonEnabled = true;
    });
  }

  void exportLogs() async {}
}
