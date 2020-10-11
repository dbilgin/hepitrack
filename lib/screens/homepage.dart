import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/models/body_part.dart';
import 'package:hepitrack/models/symptom.dart';
import 'package:hepitrack/models/water_chart_track.dart';
import 'package:hepitrack/screens/profile.dart';
import 'package:hepitrack/screens/track.dart';
import 'package:hepitrack/services/firebase_remote_config.dart';
import 'package:hepitrack/services/news_service.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/utils/db.dart';
import 'package:hepitrack/widgets/error_display.dart';
import 'package:hepitrack/widgets/loader_display.dart';
import 'package:hepitrack/widgets/news_swiper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Response> _newsList;
  Future<List<dynamic>> _trackData;
  Future<List<Symptom>> _symptoms;
  Future<List<BodyPart>> _bodyParts;
  List<Widget> dataChildren;

  double _symptomsListHeight = 0;
  double _foodListHeight = 0;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    _newsList = getNews();
    _trackData = StorageService().readTrackData();

    _symptoms = DB.symptoms();
    _bodyParts = DB.bodyParts();

    setState(() {
      dataChildren = [
        newsListBuilder(),
        waterTrackDataBuilder(),
      ];
    });
  }

  Future<Response> getNews() async {
    var remoteConfig = await FirebaseRemoteConfig.setupRemoteConfig();
    return await NewsService().getNewsList(remoteConfig);
  }

  Widget newsListBuilder() {
    return FutureBuilder<Response>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData && snapshot.data.statusCode == 200) {
          return NewsSwiper(snapshot.data.data);
        } else if (snapshot.data == null) {
          return SizedBox(
            height: 250,
            child: LoaderDisplay(),
          );
        } else {
          return Container();
        }
      },
      future: _newsList,
    );
  }

  Widget waterTrackDataBuilder() {
    return FutureBuilder<List<dynamic>>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData && snapshot.data.length > 0) {
          List<WaterChartTrack> chartData = [];

          for (var i = 0; i < snapshot.data.length; i++) {
            var currentItem = jsonDecode(snapshot.data[i]);
            var date =
                (currentItem['date_time'] ?? currentItem['date']).toString();

            var waterCount =
                int.tryParse(currentItem['water_count'].toString());

            if (waterCount != 0) {
              WaterChartTrack newWaterTrack = new WaterChartTrack(
                DateTime.parse(date),
                int.tryParse(currentItem['water_count'].toString()),
              );

              chartData.add(newWaterTrack);
            }
          }

          var seriesList = [
            new charts.Series<WaterChartTrack, DateTime>(
              id: 'Water',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (WaterChartTrack waterTrack, int i) => waterTrack.date,
              measureFn: (WaterChartTrack waterTrack, _) => waterTrack.amount,
              data: chartData,
            )
          ];

          return Column(
            children: [
              Container(
                child: Text(
                  'Water Consumption',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.all(8),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.expand(height: 350.0),
                child: charts.TimeSeriesChart(
                  seriesList,
                  animate: true,
                ),
              ),
            ],
          );
        } else if (snapshot.data == null) {
          return SizedBox(
            height: 250,
            child: LoaderDisplay(),
          );
        } else {
          return Container();
        }
      },
      future: _trackData,
    );
  }

  List<Widget> getSymptomListWidgets(String savedDate, List savedSymptomList,
      List<Symptom> symptomList, List<BodyPart> bodyPartList) {
    var mappedList = savedSymptomList.map((saved) {
      var selectedSymptom =
          symptomList.where((element) => element.id == saved['symptom']).first;

      var savedBodyPartList =
          ((saved['body_parts']?.split(',') ?? []) as List<String>);
      if (saved['body_parts'] == '') savedBodyPartList = [];

      List<BodyPart> selectedBodyParts = [];
      for (var savedPart in savedBodyPartList) {
        var selected = bodyPartList
            .where((element) => element.id == int.tryParse(savedPart))
            .first;
        selectedBodyParts.add(selected);
      }

      saved['symptom_name'] = selectedSymptom.name;
      saved['body_part_names'] = selectedBodyParts.map((e) => e.name).toList();
      return saved;
    }).toList();

    List<Widget> widgets = [];

    var dateTime = DateTime.parse(savedDate);
    var dateStr = dateTime != null
        ? DateFormat('dd-MM-yyyy – kk:mm').format(dateTime)
        : 'No Date';

    widgets.add(Text(
      dateStr,
      style: TextStyle(fontWeight: FontWeight.bold),
    ));

    for (var i = 0; i < mappedList.length; i++) {
      widgets.add(Text(mappedList[i]['symptom_name']));
      widgets.add(Text('Body Parts: ' +
          (mappedList[i]['body_part_names'] as List<String>).join(', ')));
      widgets.add(Text(
          'Intensity: ' + (mappedList[i]['intensity'] ?? 'None').toString()));

      if (i + 1 != mappedList.length) {
        widgets.add(Container(
          color: Theme.of(context).buttonColor,
          height: 1,
          margin: EdgeInsets.all(8.0),
        ));
      }
    }

    widgets.add(Container(
      color: Theme.of(context).accentColor,
      height: 1,
      margin: EdgeInsets.only(top: 8.0),
    ));

    return widgets;
  }

  getFoodListWidgets(String savedDate, List savedFoodList) {
    List<Widget> widgets = [];
    if (savedFoodList.length > 0) {
      var dateTime = DateTime.parse(savedDate);
      var dateStr = dateTime != null
          ? DateFormat('dd-MM-yyyy – kk:mm').format(dateTime)
          : 'No Date';

      widgets.add(Text(
        dateStr,
        style: TextStyle(fontWeight: FontWeight.bold),
      ));

      widgets.add(Text(
        'Tracked Food List',
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      for (var i = 0; i < savedFoodList.length; i++) {
        var currentItem = savedFoodList[i];
        var text = (i + 1).toString() +
            ': ' +
            currentItem['name'] +
            (currentItem['description'] != null
                ? ' - ' + currentItem['description']
                : '');
        widgets.add(Text(text));

        if (i + 1 != savedFoodList.length) {
          widgets.add(Container(
            color: Theme.of(context).buttonColor,
            height: 1,
            margin: EdgeInsets.all(8.0),
          ));
        }
      }

      widgets.add(Container(
        color: Theme.of(context).accentColor,
        height: 1,
        margin: EdgeInsets.only(top: 8.0),
      ));
    }
    return widgets;
  }

  Widget symptomDataBuilder() {
    return FutureBuilder<List<dynamic>>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData &&
            snapshot.data.length > 0 &&
            snapshot.data[0].length > 0 &&
            snapshot.data[1].length > 0 &&
            snapshot.data[2].length > 0) {
          var data = (snapshot.data[0] as List);

          for (var i = 0; i < data.length; i++) {
            var jsonItem = jsonDecode(data[i]);
            var symptomData = jsonDecode(data[i])['symptoms'] ??
                jsonDecode(data[i])['symptom_tracks'];
            jsonItem['symptoms'] = symptomData;

            data[i] = jsonEncode(jsonItem);
          }

          return ListView(
              padding: const EdgeInsets.all(8),
              children: data
                  .where((e) => jsonDecode(e)['symptoms'].length > 0)
                  .map((e) {
                List<Widget> widgets = getSymptomListWidgets(
                    jsonDecode(e)['date_time'] ?? jsonDecode(e)['date'],
                    jsonDecode(e)['symptoms'] as List,
                    snapshot.data[1] as List<Symptom>,
                    snapshot.data[2] as List<BodyPart>);

                return Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.grey[100],
                  child: Column(
                    children: widgets,
                  ),
                );
              }).toList());
        } else if (snapshot.data[0] == null) {
          return SizedBox(
            height: 250,
            child: LoaderDisplay(),
          );
        } else {
          return Container(
            child: Center(
              child: Text('List empty'),
            ),
          );
        }
      },
      future: Future.wait([_trackData, _symptoms, _bodyParts]),
    );
  }

  Widget foodDataBuilder() {
    return FutureBuilder<dynamic>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData && snapshot.data.length > 0) {
          return ListView(
              padding: const EdgeInsets.all(8),
              children: (snapshot.data as List)
                  .where((e) => jsonDecode(e)['food_tracks'].length > 0)
                  .map((e) {
                List<Widget> foodWidgets = getFoodListWidgets(
                    jsonDecode(e)['date_time'] ?? jsonDecode(e)['date'],
                    jsonDecode(e)['food_tracks'] as List);

                return Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.grey[100],
                  child: Column(
                    children: foodWidgets,
                  ),
                );
              }).toList());
        } else if (snapshot.data == null) {
          return SizedBox(
            height: 250,
            child: LoaderDisplay(),
          );
        } else {
          return Container(
            child: Center(
              child: Text('List empty'),
            ),
          );
        }
      },
      future: _trackData,
    );
  }

  setSymptomsHeight() {
    if (_symptomsListHeight == 0)
      setState(() {
        _symptomsListHeight = 300;
      });
    else
      setState(() {
        _symptomsListHeight = 0;
      });
  }

  setFoodHeight() {
    if (_foodListHeight == 0)
      setState(() {
        _foodListHeight = 300;
      });
    else
      setState(() {
        _foodListHeight = 0;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
            icon: Image.asset(
              'assets/user.png',
              color: Theme.of(context).primaryColor,
              height: 24,
              width: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...dataChildren,
                Container(
                  child: FlatButton(
                    onPressed: () => setSymptomsHeight(),
                    child: Row(
                      children: [
                        Icon(_symptomsListHeight == 0
                            ? Icons.arrow_right
                            : Icons.arrow_drop_down),
                        Text(
                          'Symptoms',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  margin: EdgeInsets.all(8),
                ),
                SizedBox(
                  height: _symptomsListHeight,
                  child: symptomDataBuilder(),
                ),
                Container(
                  child: FlatButton(
                    onPressed: () => setFoodHeight(),
                    child: Row(
                      children: [
                        Icon(_foodListHeight == 0
                            ? Icons.arrow_right
                            : Icons.arrow_drop_down),
                        Text(
                          'Food',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  margin: EdgeInsets.all(8),
                ),
                SizedBox(
                  height: _foodListHeight,
                  child: foodDataBuilder(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrackPage()),
          ).then((value) => getData());
        },
        tooltip: 'Track',
        child: Icon(Icons.add),
      ),
    );
  }
}
