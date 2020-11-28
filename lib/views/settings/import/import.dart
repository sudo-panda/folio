import 'dart:ui';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:folio/models/port/statement.dart';

import 'package:folio/views/settings/import/add_file.dart';
import 'package:folio/views/settings/import/add_trade_log.dart';
import 'package:folio/views/settings/import/database_actions.dart';

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
  TextEditingController _nseCodeCtl;
  TextEditingController _bseCodeCtl;
  List<Statement> _list;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _hasImported = false;
    _isButtonEnabled = true;
    _nseCodeCtl = TextEditingController();
    _bseCodeCtl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nseCodeCtl.dispose();
    _bseCodeCtl.dispose();
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
                ListTile(
                  title: Text("Choose File"),
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
                  onTap: _isButtonEnabled ? importTrades : null,
                ),
                Divider(),
                Text(
                  "Manual",
                  style: Theme.of(context).textTheme.headline6,
                ),
                ListTile(
                  title: Text("Add trade log"),
                  trailing: Icon(
                    Icons.input_outlined,
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
                  title: Text("Link stock codes across exchanges"),
                  trailing: Icon(
                    Icons.link_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: _isButtonEnabled
                      ? () async {
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Codes",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: "NSE Code",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            helperText: "NSE Code",
                                          ),
                                          cursorColor:
                                              Theme.of(context).accentColor,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          keyboardType: TextInputType.text,
                                          controller: _nseCodeCtl,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: "BSE Code",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            helperText: "BSE Code",
                                          ),
                                          cursorColor:
                                              Theme.of(context).accentColor,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          keyboardType: TextInputType.text,
                                          controller: _bseCodeCtl,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            Spacer(),
                                            FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Text("Add"),
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  DatabaseActions.linkCodes({
                                                    'NSE': _nseCodeCtl.text,
                                                    'BSE': _bseCodeCtl.text,
                                                  });
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).then((value) {
                            _nseCodeCtl.text = "";
                            _bseCodeCtl.text = "";
                          });
                        }
                      : null,
                ),
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
                    color: Colors.amberAccent
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,),
                      Expanded(
                        child: Text(
                          "Most recent entry is on: "
                          "${snapshot.data.day.toString()}-"
                          "${snapshot.data.month.toString()}-"
                          "${snapshot.data.year.toString()}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).accentColor
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
      var logs = await DatabaseActions.parseSBIFile(file); 

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AddFile(logs);
        }),
      );
    }

    setState(() {
      _hasImported = false;
      _isButtonEnabled = true;
    });
  }
}
