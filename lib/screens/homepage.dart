import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/screens/profile.dart';
import 'package:hepitrack/screens/track.dart';
import 'package:hepitrack/services/firebase_remote_config.dart';
import 'package:hepitrack/services/news_service.dart';
import 'package:hepitrack/widgets/error_display.dart';
import 'package:hepitrack/widgets/loader_display.dart';
import 'package:hepitrack/widgets/news_swiper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Response> _newsList;

  @override
  void initState() {
    _newsList = getNews();
    super.initState();
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
          child: Column(
            children: [
              newsListBuilder(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrackPage()),
          );
        },
        tooltip: 'Track',
        child: Icon(Icons.add),
      ),
    );
  }
}
