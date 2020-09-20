import 'package:flutter/material.dart';
import 'package:hepitrack/models/food_track_item.dart';

class TrackFoodProvider extends ChangeNotifier {
  List<FoodTrackItem> _foodList = [];

  List<FoodTrackItem> get foodList => _foodList;
  set foodList(List<FoodTrackItem> newValue) {
    _foodList = newValue;
    notifyListeners();
  }
}
