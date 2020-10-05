import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/models/body_part.dart';
import 'package:hepitrack/models/symptom.dart';
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
        symptomDataBuilder(),
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
          var seriesList = [
            new charts.Series<List<String>, DateTime>(
              id: 'Water',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (List<String> waterTime, int i) =>
                  DateTime.parse(waterTime[1]),
              measureFn: (List<String> waterTime, _) =>
                  int.tryParse(waterTime[0]),
              data: snapshot.data
                  .map(
                    (e) => [
                      jsonDecode(e)['water_count'].toString(),
                      jsonDecode(e)['date_time'].toString()
                    ],
                  )
                  .toList(),
            )
          ];

          return Column(
            children: [
              Text('Water Consumption'),
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
          return Column(
            children: [
              Text('Symptoms'),
              SizedBox(
                height: 350, // constrain height
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: (snapshot.data[0] as List)
                      .where((e) => jsonDecode(e)['symptoms'].length > 0)
                      .map(
                        (e) => Container(
                          height: 300,
                          color: Colors.lightBlue,
                          child: Column(
                            children: [
                              Text(jsonDecode(e)['symptoms'].toString()),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          );
        } else if (snapshot.data[0] == null) {
          return SizedBox(
            height: 250,
            child: LoaderDisplay(),
          );
        } else {
          return Container();
        }
      },
      future: Future.wait([_trackData, _symptoms, _bodyParts]),
    );
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
              children: dataChildren,
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
