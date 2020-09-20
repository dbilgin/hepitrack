class SymptomTrackItem {
  SymptomTrackItem({this.symptom, this.bodyParts, this.intensity});

  int symptom;
  List<int> bodyParts;
  int intensity;

  copy() => new SymptomTrackItem(
        symptom: symptom,
        intensity: intensity,
        bodyParts: bodyParts,
      );
}
