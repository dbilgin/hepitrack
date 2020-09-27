import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hepitrack/models/food_track_item.dart';
import 'package:hepitrack/models/symptom_track_item.dart';
import 'package:hepitrack/providers/track_food_provider.dart';
import 'package:hepitrack/providers/track_symptom_provider.dart';
import 'package:hepitrack/providers/track_view_provider.dart';
import 'package:hepitrack/providers/track_water_provider.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/services/user_service.dart';
import 'package:hepitrack/utils/dialogs.dart';
import 'package:hepitrack/widgets/tracking/track_grid.dart';
import 'package:hepitrack/widgets/tracking/track_view.dart';
import 'package:provider/provider.dart';

enum SwipeDirection {
  up,
  down,
}

class TrackPage extends StatefulWidget {
  TrackPage({Key key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  double _trackViewBottomDistance;
  final _swiperController = SwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _animateTrackView({
    @required BuildContext context,
    @required SwipeDirection swipeDirection,
    int index,
  }) {
    double height = MediaQuery.of(context).size.height;
    setState(() {
      _trackViewBottomDistance =
          swipeDirection == SwipeDirection.down ? 0 : height;
    });

    Provider.of<TrackViewProvider>(context, listen: false)
        .setAppBarTitle(index);
  }

  void updateTrackViewDistance(double distance) {
    setState(() {
      _trackViewBottomDistance = distance;
    });
  }

  Future<bool> _checkAvailability(double water, List<SymptomTrackItem> symptoms,
      List<FoodTrackItem> food) async {
    var isAuthenticated = await StorageService().isAuthenticated();
    var connectivityResult = await Connectivity().checkConnectivity();

    if (water == 0 && symptoms.length == 0 && food.length == 0) {
      Dialogs.showCustomDialog(
          context: context,
          title: "Add Data",
          message: "You need to add track data first.");
      return false;
    } else if (!isAuthenticated) {
      Dialogs.showCustomDialog(
          context: context,
          title: "Login",
          message: "You need to login first.");
      return false;
    } else if (connectivityResult == ConnectivityResult.none) {
      Dialogs.showCustomDialog(
          context: context,
          title: "Connection",
          message: "You need to be connected to the internet.");
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TrackViewProvider(),
        ),
        ChangeNotifierProvider(create: (_) => TrackSymptomProvider()),
        ChangeNotifierProvider(create: (_) => TrackFoodProvider()),
        ChangeNotifierProvider(
            create: (_) => TrackWaterProvider(waterCount: 0)),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<TrackViewProvider>(
            builder: (context, trackViewProvider, child) {
              return Text(trackViewProvider.appBarTitle);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  TrackGrid(
                    buttonCallback: (int index) {
                      _swiperController.move(index, animation: false);
                      _animateTrackView(
                        context: context,
                        swipeDirection: SwipeDirection.down,
                        index: index,
                      );
                    },
                  ),
                  TrackView(
                    swiperController: _swiperController,
                    animateTrackView: _animateTrackView,
                    bottomDistance: _trackViewBottomDistance,
                    updateTrackViewDistance: updateTrackViewDistance,
                  ),
                ],
              ),
            ),
            Consumer4<TrackViewProvider, TrackSymptomProvider,
                TrackFoodProvider, TrackWaterProvider>(
              builder: (
                context,
                trackViewProvider,
                trackSymptomProvider,
                trackFoodProvider,
                trackWaterProvider,
                child,
              ) {
                return SafeArea(
                  child: SizedBox(
                    height: trackViewProvider.saveButtonHeight,
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () async {
                        List<SymptomTrackItem> symptoms =
                            trackSymptomProvider.symptomList;
                        List<FoodTrackItem> food = trackFoodProvider.foodList;
                        double water = trackWaterProvider.waterCount;

                        if (!(await _checkAvailability(
                            water, symptoms, food))) {
                          return;
                        }

                        Dialogs.showLoading(context);

                        var savedDate = DateTime.now().toIso8601String();
                        var trackData = {
                          'water_count': water.round(),
                          'symptoms': symptoms.map((e) => e.toJson()).toList(),
                          'food_tracks': food.map((e) => e.toJson()).toList(),
                          'date_time': savedDate,
                        };
                        var trackResult =
                            await UserService().addTrack(trackData);

                        Navigator.pop(context);
                        if (trackResult.statusCode == 204) {
                          var stringifiedTrack = trackData.toString();
                          await StorageService().addTrackData(stringifiedTrack);
                          Navigator.pop(context);
                        } else {
                          Dialogs.showCustomDialog(context: context);
                        }
                      },
                      child: Text('Save All'),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
