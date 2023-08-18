import 'package:flutter/material.dart';
import 'package:folio/assets/app_theme.dart';
import 'package:folio/views/tracked/tracked.dart';

class FolioApp extends StatefulWidget {
  @override
  _FolioAppState createState() => _FolioAppState();

  /// InheritedWidget style accessor to our State object.
  static _FolioAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_FolioAppState>()!;
}

class _FolioAppState extends State<FolioApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: TrackedView(),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void invertTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  bool isLightTheme() {
    return _themeMode == ThemeMode.light;
  }
}