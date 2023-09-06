import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/views/settings/data/scrips_list.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:folio/views/settings/data/add_portfolio_dialog.dart';
import 'package:folio/views/settings/data/add_trade_log.dart';
import 'package:folio/views/settings/data/track_stock_dialog.dart';
import 'package:folio/helpers/database_actions.dart';

import 'import_file/import_file.dart';

class ImportRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Data"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          SizedBox(
            width: 50.0,
            child: Icon(Icons.table_chart_outlined),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromViewPadding(ViewPadding.zero, 1),
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
  late bool _isButtonEnabled;
  late bool _isImporting;
  late bool _isExporting;
  final DateFormat _fileFormatter = DateFormat('folio-yyyy-MMM-dd-HH-mm-ss');

  @override
  void initState() {
    super.initState();
    _isButtonEnabled = true;
    _isImporting = false;
    _isExporting = false;
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
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text("Import File"),
                  trailing: _isImporting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : Icon(
                          Icons.folder_open_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  onTap: !_isButtonEnabled
                      ? null
                      : () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ImportFileRoute();
                          }));
                        },
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
                  "Securities",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text("Show Securities"),
                  trailing: Icon(
                    Icons.view_list_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: !_isButtonEnabled
                      ? null
                      : () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return ShowSecuritiesRoute();
                        }));
                  },
                ),
                Divider(),
                Text(
                  "Export",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text("Export to CSV"),
                  trailing: _isExporting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : Icon(
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
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  title: Text("Delete Database"),
                  onTap: () async {
                    await deleteDatabase(context);
                  },
                )
              ],
            ),
          ),
          Spacer(),
          FutureBuilder(
            future: DatabaseActions.getRecentDate(),
            builder: (context, AsyncSnapshot snapshot) {
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
                          "${snapshot.data?.day.toString()}-"
                          "${snapshot.data?.month.toString()}-"
                          "${snapshot.data?.year.toString()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.secondary),
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

  Future<void> deleteDatabase(BuildContext context) async {
    String? result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child: Text("WARNING")),
        content: Text(
          "This will delete the database. Proceed only if you know what you are doing.",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                minimumSize: Size(88, 36),
                padding: EdgeInsets.symmetric(horizontal: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(5)),
                )),
            onPressed: () {
              Navigator.pop(context, "Delete");
            },
            child: Text("Delete"),
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.background,
              minimumSize: Size(88, 36),
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(5)),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
            child: Text("Cancel"),
          ),
        ],
        actionsPadding:
            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
    if (result == "Delete") {
      DatabaseActions.deleteDbThenInit();
    }
  }

  void exportLogs() async {
    setState(() {
      _isButtonEnabled = false;
      _isExporting = true;
    });
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (!storageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) {
      String csv = await DatabaseActions.getTradesCSV();

      String fileName = _fileFormatter.format(DateTime.now());
      File file = File('$dir/$fileName.csv');

      file.writeAsString(csv);
    }

    setState(() {
      _isButtonEnabled = true;
      _isExporting = false;
    });
  }
}
