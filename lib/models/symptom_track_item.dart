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

  SymptomTrackItem.fromJson(Map<String, dynamic> json)
      : symptom = json['symptom'],
        bodyParts = json['bodyParts']
                ?.toString()
                ?.split(',')
                ?.map((data) => int.parse(data))
                ?.toList() ??
            [],
        intensity = json['intensity'];

  Map<String, dynamic> toJson() {
    return {
      'symptom': symptom,
      'body_parts': bodyParts.join(','),
      'intensity': intensity,
    };
  }
}
