import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/views/settings/data/import_file/show_valid_logs.dart';

import '../../../../helpers/database_actions.dart';
import '../../../../models/trade/parsed_file_logs.dart';
import 'correct_invalid_logs.dart';

class ImportFileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportFileRouteState();
}

class _ImportFileRouteState extends State<ImportFileRoute> {
  PlatformFile? pickedFile;
  bool _isButtonEnabled = true;
  String? _message;
  int? _current;
  int? _total;

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
      onWillPop: () async => _isButtonEnabled,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Select File")),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.circle_outlined,
                color: Theme.of(context).colorScheme.background,
              ),
              onPressed: null,
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: InkWell(
                      onTap: _isButtonEnabled ? pickFile : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 9,
                              child: Text(
                                pickedFile?.path == null
                                    ? ""
                                    : pickedFile!.path!.substring(
                                        pickedFile!.path!.lastIndexOf("/") + 1),
                                softWrap: true,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(Icons.file_open),
                                onPressed: _isButtonEnabled ? pickFile : null,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isButtonEnabled && pickedFile?.path != null
                  ? importLogs
                  : null,
              child: Text(
                "Import",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
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
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  void pickFile() async {
    setState(() {
      _isButtonEnabled = false;
    });

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result == null || result.files.first.path == null) {
      setState(() {
        pickedFile = null;
        _isButtonEnabled = true;
      });

      return;
    }

    setState(() {
      pickedFile = result.files.first;
      _isButtonEnabled = true;
    });

    return;
  }

  void importLogs() async {
    if (pickedFile == null || pickedFile?.path == null) {
      return;
    }

    setState(() {
      _isButtonEnabled = false;
    });
    updateProgress(message: "Importing File");

    ParsedFileLogs logs;
    String filePath = pickedFile!.path!;

    try {
      switch (pickedFile?.extension) {
        case "csv":
          String file = "";
          try {
            file = File(pickedFile!.path!).readAsStringSync();
          } catch (e) {
            log("data.importLogs() => Error in reading file\n " + e.toString());
            updateProgress(
                message: "Error in reading file", current: 0, total: 1);
            setState(() {
              _isButtonEnabled = true;
            });
            return;
          }
          updateProgress(message: "Parsing CSV File");
          logs = await DatabaseActions.parseCSVFile(file,
              onUpdate: updateProgress);
          break;
        case "xls":
          String file = "";
          try {
            file = File(pickedFile!.path!).readAsStringSync();
          } catch (e) {
            log("data.importLogs() => Error in reading file\n " + e.toString());
            setState(() {
              _isButtonEnabled = true;
            });
            updateProgress(
                message: "Error in reading file", current: 0, total: 1);
            return;
          }
          updateProgress(message: "Parsing SBI File (old format)");
          logs = await DatabaseActions.parseOldSBIFile(file,
              onUpdate: updateProgress);
          break;
        case "xlsx":
          logs = await DatabaseActions.parseSBIFile(filePath,
              onUpdate: updateProgress);
          break;
        default:
          setState(() {
            _isButtonEnabled = true;
          });
          updateProgress();
          return;
      }
    } catch (e) {
      // FIXME: Send error to user
      updateProgress(message: e.toString(), current: 0, total: 1);
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    if (logs.invalidLogs.length != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return CorrectInvalidLogs(logs);
        }),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return ShowValidLogs(logs.validLogs);
        }),
      );
    }

    setState(() {
      _isButtonEnabled = true;
    });
  }
}
