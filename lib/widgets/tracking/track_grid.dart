import 'package:flutter/material.dart';
import 'package:hepitrack/providers/track_food_provider.dart';
import 'package:hepitrack/providers/track_symptom_provider.dart';
import 'package:hepitrack/providers/track_water_provider.dart';
import 'package:provider/provider.dart';

import '../grid_button.dart';

class TrackGrid extends StatefulWidget {
  TrackGrid({
    Key key,
    this.buttonCallback,
  }) : super(key: key);

  final Function buttonCallback;

  @override
  _TrackGridState createState() => _TrackGridState();
}

class _TrackGridState extends State<TrackGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        GridButton(
          buttonCallback: () => widget.buttonCallback(0),
          text: 'Symptom',
          image: Image.asset(
            'assets/tracking/symptom.png',
            fit: BoxFit.cover,
            color: Colors.white,
          ),
          isFilled:
              (Provider.of<TrackSymptomProvider>(context).symptomList ?? [])
                      .length >
                  0,
        ),
        GridButton(
          buttonCallback: () => widget.buttonCallback(1),
          text: 'Food',
          image: Image.asset(
            'assets/tracking/food.png',
            fit: BoxFit.cover,
            color: Colors.white,
          ),
          isFilled:
              (Provider.of<TrackFoodProvider>(context).foodList ?? []).length >
                  0,
        ),
        GridButton(
          buttonCallback: () => widget.buttonCallback(2),
          text: 'Water',
          image: Image.asset(
            'assets/tracking/water_full.png',
            fit: BoxFit.cover,
            color: Colors.white,
          ),
          isFilled:
              Provider.of<TrackWaterProvider>(context).waterCount != null &&
                  Provider.of<TrackWaterProvider>(context).waterCount > 0,
        ),
      ],
    );
  }
}
