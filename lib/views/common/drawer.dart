import 'package:flutter/material.dart';
import 'package:folio/folio_app.dart';
import 'package:folio/views/settings/drive/drive.dart';
import 'package:folio/views/settings/data/data.dart';

class FolioDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        semanticLabel: "Settings",
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Container(
                      color: Colors.lightGreen,
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                iconSize: 30,
                                icon: FolioApp.of(context).isLightTheme()
                                    ? Icon(
                                        Icons.wb_sunny_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )
                                    : Icon(
                                        Icons.nights_stay_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                onPressed: () {
                                  FolioApp.of(context).invertTheme();
                                }),
                          ),
                          Spacer(),
                          Text(
                            "folio",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.table_chart_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    title: Text("Manage Data"),
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
                    leading: Icon(
                      Icons.cloud_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
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
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
