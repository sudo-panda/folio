import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  String _message = "";
  int? total;
  int? _current;

  String get message => _message;

  set message(String message) {
    _message = message;

    notifyListeners();
  }

  int? get current => _current;

  set current(int? current) {
    _current = current;

    notifyListeners();
  }

  void init(String message, int current, int total) {
    _message = message;
    _current = current;
    total = total;

    notifyListeners();
  }
}