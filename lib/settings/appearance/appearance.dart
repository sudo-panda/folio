import 'package:flutter/material.dart';

import 'dropdown.dart';

class AppearanceRoute extends StatelessWidget {
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
                  child: Dropdown(<String>['Light', 'Dark', 'System'], 0),
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
                  child: Dropdown(<String>['Sensex', 'Nifty'], 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
