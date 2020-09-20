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
}
