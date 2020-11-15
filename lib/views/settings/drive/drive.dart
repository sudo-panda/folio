import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/services/google_api/google_auth_client.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

class DriveRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drive"),
        centerTitle: true,
        elevation: 0,
        actions: [
          SizedBox(
            width: 50.0,
            child: Icon(Icons.cloud_queue_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromWindowPadding(WindowPadding.zero, 1),
          child: DriveArea(),
        ),
      ),
    );
  }
}

class DriveArea extends StatefulWidget {
  @override
  _DriveAreaState createState() => _DriveAreaState();
}

class _DriveAreaState extends State<DriveArea> {
  bool _isProcessing;
  bool _isBackingUp;
  bool _isRestoring;
  bool _isDeleting;
  signIn.GoogleSignInAccount account;
  final DateFormat _fileFormatter = DateFormat('folio-y-M-d-H-m-s');
  signIn.GoogleSignIn googleSignIn;

  @override
  void initState() {
    super.initState();
    login();
    _isProcessing = true;
    _isBackingUp = false;
    _isRestoring = false;
    _isDeleting = false;
  }

  void login() async {
    try {
      googleSignIn = signIn.GoogleSignIn.standard(
          scopes: [drive.DriveApi.DriveAppdataScope]);
      account = await googleSignIn.signIn();
      if (account == null) throw Exception();
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                ListTile(
                  leading: _isBackingUp
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : Icon(Icons.cloud_upload_outlined),
                  title: Text("Backup"),
                  onTap: _isProcessing ? null : backup,
                ),
                ListTile(
                  leading: _isRestoring
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : Icon(Icons.cloud_download_outlined),
                  title: Text("Restore"),
                  onTap: _isProcessing ? null : showRestoreDialog,
                ),
                ListTile(
                  leading: _isDeleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : Icon(Icons.cloud_off_rounded),
                  title: Text("Delete"),
                  onTap: _isProcessing ? null : showDeleteDialog,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 80,
                child: account == null
                    ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Center(
                        child: ListTile(
                          title: Text("Logged in as: ${account.displayName}"),
                          subtitle: Text("${account.email}"),
                          trailing: IconButton(
                              icon: Icon(Icons.logout),
                              onPressed: () {
                                googleSignIn.signOut();
                                Navigator.pop(context);
                              }),
                          isThreeLine: true,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backup() async {
    setState(() {
      _isBackingUp = true;
      _isProcessing = true;
    });

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    final path = await DatabaseHelper().getDbPath();
    final file = File(path);

    var media = drive.Media(file.openRead(), file.lengthSync());

    var driveFile = drive.File();
    driveFile.name = _fileFormatter.format(DateTime.now());
    driveFile.parents = ["appDataFolder"];
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");

    setState(() {
      _isBackingUp = false;
      _isProcessing = false;
    });
  }

  void showRestoreDialog() async {
    setState(() {
      _isProcessing = true;
    });
    String id = await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        title: Text('Restore Backup'),
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 250,
              width: double.maxFinite,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: FutureBuilder(
                future: getBackups(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.files.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.storage_outlined),
                          title: Text("${snapshot.data.files[index].name}"),
                          onTap: () {
                            Navigator.pop(
                                context, "${snapshot.data.files[index].id}");
                          },
                        );
                      },
                    );
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Text("No Data"),
                    );
                  }
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                color: Theme.of(context).buttonColor,
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: Text("Cancel"),
              ),
              SizedBox(
                width: 30,
              )
            ],
          )
        ],
      ),
    );

    if (id != null) {
      setState(() {
        _isRestoring = true;
      });

      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      drive.Media file = await driveApi.files
          .get(id, downloadOptions: drive.DownloadOptions.FullMedia);

      final saveFile = File(await DatabaseHelper().getDbPath());
      List<int> dataStore = [];
      file.stream.listen((data) {
        print("DataReceived: ${data.length}");
        dataStore.insertAll(dataStore.length, data);
      }, onDone: () async {
        print("Task Done");
        saveFile.writeAsBytes(dataStore, flush: true).then((res) async {
          print("Written to File");
        });
      }, onError: (error) {
        print("Error: ${error.toString()}");
      });
    }
    print("Restores");
    setState(() {
      _isRestoring = false;
      _isProcessing = false;
    });
  }

  void showDeleteDialog() async {
    setState(() {
      _isProcessing = true;
    });

    String id = await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        title: Text('Delete Backup'),
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 250,
              width: double.maxFinite,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: FutureBuilder(
                future: getBackups(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.files.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.storage_outlined),
                          title: Text("${snapshot.data.files[index].name}"),
                          onTap: () {
                            Navigator.pop(
                                context, "${snapshot.data.files[index].id}");
                          },
                        );
                      },
                    );
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Text("No Backups Found"),
                    );
                  }
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                color: Theme.of(context).buttonColor,
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: Text("Cancel"),
              ),
              SizedBox(
                width: 30,
              )
            ],
          )
        ],
      ),
    );

    if (id != null) {
      setState(() {
        _isDeleting = true;
      });

      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      driveApi.files.delete(id);
    }

    setState(() {
      _isDeleting = false;
      _isProcessing = false;
    });
  }

  Future<dynamic> getBackups() async {
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    return await driveApi.files.list(spaces: 'appDataFolder');
  }
}
