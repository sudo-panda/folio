import 'package:flutter/material.dart';
import 'package:folio/preferences/shared_preferences_helper.dart';

import 'dropdown.dart';

class AppearanceRoute extends StatefulWidget {
  @override
  _AppearanceRouteState createState() => _AppearanceRouteState();
}

class _AppearanceRouteState extends State<AppearanceRoute> {
  static List<String> themes = ['Light', 'Dark', 'System'];
  static List<String> indices = ['Sensex', 'Nifty'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appearance"),
        centerTitle: true,
        elevation: 0,
        actions: [
          SizedBox(
            width: 50.0,
            child: Icon(Icons.phone_android),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 30,
                  child: Icon(Icons.brightness_medium),
                ),
                Expanded(child: Text("Theme")),
                Expanded(
                  child: FutureBuilder<String>(
                    future: SharedPreferencesHelper().getString('theme'),
                    initialData: themes[0],
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.done
                          ? Dropdown(
                              themes,
                              snapshot.hasData? snapshot.data : themes[0],
                              (String newValue) {
                                SharedPreferencesHelper()
                                    .setString('theme', newValue);
                              },
                            )
                          : Container();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 30,
                  child: Icon(Icons.show_chart),
                ),
                Expanded(child: Text("Main Index")),
                Expanded(
                  child: FutureBuilder<String>(
                    future: SharedPreferencesHelper().getString('index'),
                    initialData: indices[0],
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.done
                          ? Dropdown(
                              indices,
                              snapshot.hasData? snapshot.data : indices[0],
                              (String newValue) {
                                SharedPreferencesHelper()
                                    .setString('index', newValue);
                              },
                            )
                          : Container();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
