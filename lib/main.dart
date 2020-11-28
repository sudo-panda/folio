// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:folio/assets/app_theme.dart';
import 'package:folio/state/app_state.dart';
import 'package:folio/views/tracked/tracked.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Folio',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
          home: TrackedView(),
        );
      },
    );
  }
}
