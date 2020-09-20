import 'package:flutter/material.dart';

class TrackWaterProvider extends ChangeNotifier {
  TrackWaterProvider({double waterCount}) : _waterCount = waterCount;
  double _waterCount;

  double get waterCount => _waterCount;

  set waterCount(double newValue) {
    _waterCount = newValue;
    notifyListeners();
  }
}
