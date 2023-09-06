import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/views/settings/data/import_scrips_list/parsed_scrips.dart';

import 'package:folio/helpers/database_actions.dart';
import 'package:folio/views/settings/data/import_scrips_list/show_scrips.dart';

class ImportScripsFileRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportScripsFileRouteState();
}

class _ImportScripsFileRouteState extends State<ImportScripsFileRoute> {
  PlatformFile? pickedFile;
  bool _isButtonEnabled = true;
  String? _message;
  int? _current;
  int? _total;
  List<bool> _isExchangeSelected = [true, false];
  List<String> _exchanges = ["BSE", "NSE"];

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
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                color: Theme.of(context).colorScheme.background,
                margin: EdgeInsets.all(10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ToggleButtons(
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              child: Text(
                                "BSE",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: _isExchangeSelected[0]
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              child: Text(
                                "NSE",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: _isExchangeSelected[1]
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    ),
                              ),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < _isExchangeSelected.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  _isExchangeSelected[buttonIndex] = true;
                                } else {
                                  _isExchangeSelected[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: _isExchangeSelected,
                          selectedColor: _isExchangeSelected[0]
                              ? Colors.lightBlue
                              : Colors.orange,
                          fillColor: _isExchangeSelected[0]
                              ? Colors.lightBlue
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Container(
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
                                            pickedFile!.path!.lastIndexOf("/") +
                                                1),
                                    softWrap: true,
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.file_open),
                                    onPressed:
                                        _isButtonEnabled ? pickFile : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed:
                              _isButtonEnabled && pickedFile?.path != null
                                  ? importScrips
                                  : null,
                          child: Text(
                            "Import",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
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

  String getSelectedExchange() {
    for (int i = 0; i < _isExchangeSelected.length; i++) {
      if (_isExchangeSelected[i]) {
        return _exchanges[i];
      }
    }
    return "";
  }

  void importScrips() async {
    if (pickedFile == null || pickedFile?.path == null) {
      return;
    }

    setState(() {
      _isButtonEnabled = false;
    });
    updateProgress(message: "Importing File");

    ParsedScripsList scripsList;
    String filePath = pickedFile!.path!;

    try {
      switch (pickedFile?.extension) {
        case "csv":
          String file = "";
          try {
            file = File(filePath).readAsStringSync();
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
          scripsList = await DatabaseActions.parseCSVScripsFile(
              getSelectedExchange(), file,
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
      updateProgress(message: e.toString(), current: 0, total: 1);
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return ShowScrips(scripsList);
      }),
    );

    setState(() {
      _isButtonEnabled = true;
    });
  }
}
