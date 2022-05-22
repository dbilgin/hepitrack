import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hepitrack/providers/track_view_provider.dart';
import 'package:hepitrack/providers/track_water_provider.dart';
import 'package:provider/provider.dart';

import '../animated_wave.dart';
import '../slider_widget.dart';

class TrackWater extends StatefulWidget {
  TrackWater({
    Key key,
  }) : super(key: key);

  @override
  _TrackWaterState createState() => _TrackWaterState();
}

class _TrackWaterState extends State<TrackWater> {
  Image _waterIcon;

  @override
  void initState() {
    new Future.delayed(Duration.zero, () {
      _setWaterIcon(
          Provider.of<TrackWaterProvider>(context, listen: false).waterCount);
    });

    super.initState();
  }

  _setWaterIcon(double value) {
    if (value <= 1) {
      setState(
        () => _waterIcon = Image.asset(
          'assets/tracking/water_empty.png',
          color: Theme.of(context).primaryColor,
        ),
      );
    } else if (value >= 2 && value <= 3) {
      setState(
        () => _waterIcon = Image.asset(
          'assets/tracking/water_little.png',
          color: Theme.of(context).primaryColor,
        ),
      );
    } else if (value >= 4 && value <= 6) {
      setState(
        () => _waterIcon = Image.asset(
          'assets/tracking/water_half.png',
          color: Theme.of(context).primaryColor,
        ),
      );
    } else if (value >= 7) {
      setState(
        () => _waterIcon = Image.asset(
          'assets/tracking/water_full.png',
          color: Theme.of(context).primaryColor,
          height: 128,
          width: 128,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical -
        Provider.of<TrackViewProvider>(context).saveButtonHeight;

    const waveData = [
      {
        "speed": 1.0,
        "offset": 0.0,
      },
      {
        "speed": 0.9,
        "offset": pi,
      },
      {
        "speed": 1.2,
        "offset": pi / 2,
      }
    ];

    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                SliderWidget(
                  value: Provider.of<TrackWaterProvider>(context, listen: true)
                      .waterCount,
                  onChanged: (value) {
                    Provider.of<TrackWaterProvider>(context, listen: false)
                        .waterCount = value;
                    _setWaterIcon(value);
                  },
                  fullWidth: true,
                  min: 0,
                  max: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '*Glasses of water',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: (_waterIcon ??
                      Image.asset(
                        'assets/tracking/water_empty.png',
                        color: Theme.of(context).primaryColor,
                      )),
                ),
              ],
            ),
          ),
          for (var wave in waveData)
            Positioned(
              top: height -
                  (height *
                      Provider.of<TrackWaterProvider>(context, listen: true)
                          .waterCount /
                      10),
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedWave(
                speed: wave["speed"],
                offset: wave["offset"],
              ),
            ),
        ],
      ),
    );
  }
}
