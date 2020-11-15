import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';
import 'package:folio/views/settings/drive/drive.dart';
import 'appearance/appearance.dart';
import 'import/import.dart';

class SettingsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Careful!"),
              content: Text(
                  "This will delete the database. Proceed only if you know what you are doing."),
              actions: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
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
                    borderRadius: BorderRadius.all(Radius.circular(5)),
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
            DatabaseHelper().deleteDbThenInit();
          }
        },
        backgroundColor: Color.fromARGB(200, 255, 50, 50),
        child: Icon(
          Icons.delete_forever_outlined,
          size: 30,
          color: Theme.of(context).accentColor,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text("Appearance"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return AppearanceRoute();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("Import"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ImportRoute();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_outlined),
            title: Text("Drive"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return DriveRoute();
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
