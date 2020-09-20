import 'package:flutter/material.dart';
import 'package:hepitrack/models/symptom_track_item.dart';

class TrackSymptomProvider extends ChangeNotifier {
  List<SymptomTrackItem> _symptomList = [];

  List<SymptomTrackItem> get symptomList => _symptomList;
  set symptomList(List<SymptomTrackItem> newValue) {
    _symptomList = newValue;
    notifyListeners();
  }
}
