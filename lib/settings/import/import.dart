import 'dart:developer';
import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';

import 'parser/sbi_parser.dart';

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
  bool _isButtonEnabled;

  @override
  void initState() {
    super.initState();
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
        children: [
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
                child: _isButtonEnabled ? Text("Browse") : SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1,)),
                onPressed: _isButtonEnabled ? importTrades : null,
              )
            ],
          )
        ],
      ),
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

      var list = SBIParser(file).statementsList;

      await DatabaseHelper().updateFromStatements(list);
    }

    setState(() {
      _isButtonEnabled = true;
    });
  }
}
