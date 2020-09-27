import 'dart:io';

class FoodTrackItem {
  FoodTrackItem({this.name, this.description, this.image});

  String name;
  String description;
  File image;

  copy() => new FoodTrackItem(
        name: name,
        description: description,
        image: image,
      );

  FoodTrackItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
