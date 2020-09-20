import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hepitrack/providers/track_food_provider.dart';
import 'package:provider/provider.dart';

import '../../screens/food_page.dart';
import '../image_picker_button.dart';

class TrackFood extends StatefulWidget {
  TrackFood({
    Key key,
  }) : super(key: key);

  @override
  _TrackFoodState createState() => _TrackFoodState();
}

class _TrackFoodState extends State<TrackFood> {
  _setFoodImage(File imageFile, int index) {
    var currentList =
        Provider.of<TrackFoodProvider>(context, listen: false).foodList;
    currentList[index].image = imageFile;

    Provider.of<TrackFoodProvider>(context, listen: false).foodList =
        currentList;
  }

  _addNewFood({int index}) async {
    var list = Provider.of<TrackFoodProvider>(context, listen: false).foodList;

    FoodPage addFood;
    if (index != null) {
      var currentItem = list[index];
      addFood = FoodPage(foodTrackItem: currentItem.copy());
    } else {
      addFood = FoodPage();
    }

    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => addFood),
    );
    if (result != null) {
      if (index == null) {
        list.add(result);
      } else {
        list[index] = result;
      }
      Provider.of<TrackFoodProvider>(context, listen: false).foodList = list;
    }
  }

  _removeFood(int index) async {
    var currentList =
        Provider.of<TrackFoodProvider>(context, listen: false).foodList;
    var image = currentList[index].image;
    if (image != null && await image.exists()) {
      image.delete();
    }

    currentList.removeAt(index);
    Provider.of<TrackFoodProvider>(context, listen: false).foodList =
        currentList;
  }

  @override
  Widget build(BuildContext context) {
    var list = Provider.of<TrackFoodProvider>(context)
        .foodList
        .asMap()
        .entries
        .map(
          (entry) => ListTile(
            onTap: () => _addNewFood(index: entry.key),
            leading: SizedBox(
              width: 48,
              height: 48,
              child: ImagePickerButton(
                key: Key(entry.value.image?.path ??
                    'foodListImage' + entry.key.toString()),
                heroTag: 'foodListImage' + entry.key.toString(),
                defaultAssetPath: 'assets/tracking/food.png',
                initialFile: entry.value.image,
                onChanged: (File imageFile) =>
                    _setFoodImage(imageFile, entry.key),
              ),
            ),
            title: Text(
              entry.value.name,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            trailing: IconButton(
              onPressed: () => _removeFood(entry.key),
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        )
        .toList();

    list.add(
      ListTile(
        onTap: () => _addNewFood(),
        leading: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
        title: Text(
          'Add new',
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );

    return ListView(
      children: list,
    );
  }
}
