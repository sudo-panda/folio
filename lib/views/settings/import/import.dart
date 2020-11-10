import 'dart:developer';
import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/models/trades/trade_log.dart';

import 'package:folio/services/parser/sbi_parser.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: _hasImported ? acceptPrompt() : importPrompt(),
      ),
    );
  }

  List<Widget> importPrompt() {
    return [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
            child: Text("Choose File"),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
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
    ];
  }

  List<Widget> acceptPrompt() {
    return [
      Column(
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
      )
    ];
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
      var list = SBIParser(file).statementsList;

      list.forEach((element) {
        log(element.toString());
      });

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
