import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/models/trades/trade_log.dart';

import 'package:folio/services/parser/sbi_parser.dart';
import 'package:folio/views/settings/import/database_access.dart';
import 'package:folio/views/settings/import/table.dart';

class ImportRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import"),
        centerTitle: true,
        elevation: 0,
        actions: [
          SizedBox(
            width: 50.0,
            child: Icon(Icons.input),
          ),
        ],
      ),
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
  bool _hasImported;
  bool _isButtonEnabled;
  List<TradeLog> _list;

  @override
  void initState() {
    super.initState();
    _hasImported = false;
    _isButtonEnabled = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future: DatabaseAccess.getRecentDate(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Color(0xAAF0B450),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded),
                      Expanded(
                        child: Text(
                          "Most recent entry is on: "
                          "${snapshot.data.day.toString()}-"
                          "${snapshot.data.month.toString()}-"
                          "${snapshot.data.year.toString()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
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
          Expanded(
            child: _hasImported ? acceptPrompt() : importPrompt(),
          ),
        ],
      ),
    );
  }

  Widget importPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Choose File",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: _isButtonEnabled
                  ? Text("Browse")
                  : SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      )),
              onPressed: _isButtonEnabled ? importTrades : null,
            )
          ],
        )
      ],
    );
  }

  Widget acceptPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TradeTable(_list),
        Text("Total trades: ${_list.length}"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RaisedButton(
                child: _isButtonEnabled
                    ? Text("Accept")
                    : SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                onPressed: _isButtonEnabled ? acceptTrades : null,
              ),
              RaisedButton(
                child: Text("Cancel"),
                onPressed: _isButtonEnabled ? rejectTrades : null,
              )
            ],
          ),
        )
      ],
    );
  }

  void importTrades() async {
    setState(() {
      _isButtonEnabled = false;
    });

    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      String filePath = result.files.first.path;
      String file = File(filePath).readAsStringSync();

      setState(() {
        _list = SBIParser(file).statementsList;
        _hasImported = true;
        _isButtonEnabled = true;
      });
    }
  }

  void rejectTrades() {
    setState(() {
      _list = [];
      _isButtonEnabled = true;
      _hasImported = false;
    });
  }

  void acceptTrades() async {
    setState(() {
      _isButtonEnabled = false;
    });

    await DatabaseHelper().updateFromTradeLogs(_list);

    setState(() {
      _list = [];
      _isButtonEnabled = true;
      _hasImported = false;
    });
  }
}
