import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hepitrack/providers/track_view_provider.dart';
import 'package:hepitrack/screens/track.dart';
import 'package:hepitrack/widgets/tracking/track_food.dart';
import 'package:hepitrack/widgets/tracking/track_symptom.dart';
import 'package:hepitrack/widgets/tracking/track_water.dart';
import 'package:provider/provider.dart';

import 'track_handle.dart';

class TrackView extends StatefulWidget {
  TrackView({
    Key key,
    @required this.swiperController,
    @required this.bottomDistance,
    @required this.updateTrackViewDistance,
    @required this.animateTrackView,
  }) : super(key: key);

  final SwiperController swiperController;
  final double bottomDistance;
  final Function animateTrackView;
  final Function updateTrackViewDistance;

  @override
  _TrackViewState createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  int _animationDurationMill = 350;

  void _dragUpdate(double yPos) {
    setState(() {
      _animationDurationMill = 0;
    });
    widget.updateTrackViewDistance(yPos);
  }

  void _dragEnd() {
    setState(() {
      _animationDurationMill = 350;
    });
    double screenHeight = MediaQuery.of(context).size.height;
    if (widget.bottomDistance > (screenHeight / 4)) {
      widget.animateTrackView(
          context: context, swipeDirection: SwipeDirection.up);
    } else {
      widget.animateTrackView(
          context: context, swipeDirection: SwipeDirection.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(
        milliseconds: _animationDurationMill,
      ),
      curve: Curves.linear,
      top: 0,
      bottom: widget.bottomDistance ?? MediaQuery.of(context).size.height,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          children: <Widget>[
            new Swiper(
              onIndexChanged: (int index) {
                Provider.of<TrackViewProvider>(context, listen: false)
                    .setAppBarTitle(index);
              },
              controller: widget.swiperController,
              itemBuilder: (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return TrackSymptom();
                  case 1:
                    return TrackFood();
                  case 2:
                    return TrackWater();
                  default:
                    return null;
                }
              },
              itemCount: 3,
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: TrackHandle(
                dragUpdate: _dragUpdate,
                dragEnd: _dragEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
