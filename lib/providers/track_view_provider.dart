import 'package:flutter/material.dart';

class TrackViewProvider extends ChangeNotifier {
  double _saveButtonHeight = 50;
  String _appBarTitle = 'Track';

  double get saveButtonHeight => _saveButtonHeight;

  String get appBarTitle => _appBarTitle;
  set appBarTitle(String newValue) {
    _appBarTitle = newValue;
    notifyListeners();
  }

  void setAppBarTitle(int index) {
    var title = '';
    switch (index) {
      case 0:
        title = 'Track Symptom';
        break;
      case 1:
        title = 'Track Food';
        break;
      case 2:
        title = 'Track Water';
        break;
      default:
        title = 'Track';
        break;
    }
    appBarTitle = title;
  }
}
