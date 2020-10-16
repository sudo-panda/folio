import 'package:flutter/material.dart';
import 'package:folio/database/database_helper.dart';
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
        onPressed: () {
          print("deleting...");
          DatabaseHelper().deleteDatabase();
          print("deleted...");
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
        ],
      ),
    );
  }
}
