// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:folio/state/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'folio_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var prefs = await SharedPreferences.getInstance();

  runApp(ChangeNotifierProvider<AppState>(
    create: (context) => AppState(prefs),
    child: FolioApp(),
  ));
}


