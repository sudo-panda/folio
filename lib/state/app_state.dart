import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  late bool isDarkModeOn;
  final SharedPreferences _prefs;

  AppState(this._prefs) {
    isDarkModeOn = _prefs.getBool("theme") ?? false;
  }

  void updateTheme(bool isDarkModeOn) {
    this.isDarkModeOn = isDarkModeOn;
    notifyListeners();
    _prefs.setBool("theme", this.isDarkModeOn);
  }
}
