class Symptom {
  Symptom({this.id, this.name, this.image, this.defaultBodyPart});

  int id;
  String name;
  String image;
  int defaultBodyPart;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'default_body_part': defaultBodyPart,
    };
  }
}
