class BodyPart {
  BodyPart({this.id, this.name});

  int id;
  String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
