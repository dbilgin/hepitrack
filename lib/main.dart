import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hepitrack/services/user_service.dart';
import 'package:hepitrack/utils/common.dart';

import 'screens/homepage.dart';
import 'services/storage_service.dart';
import 'utils/hex_color.dart';

class AppThemes {
  static const int Light = 0;
  static const int Dark = 1;
}

final themeCollection = (Color appBarColor) {
  return ThemeCollection(
    themes: {
      AppThemes.Light: Common.getThemeData(
        brightness: Brightness.light,
        appBarColor: appBarColor,
      ),
      AppThemes.Dark: Common.getThemeData(
        brightness: Brightness.dark,
        appBarColor: appBarColor,
      ),
    },
    fallbackTheme: ThemeData.light(),
  );
};

void main() {
  runApp(HepiTrack());
}

class HepiTrack extends StatefulWidget {
  @override
  _HepiTrackState createState() => _HepiTrackState();
}

class _HepiTrackState extends State<HepiTrack> {
  Future<Color> _readUserColor;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  _getUserData() async {
    var storageColor = await StorageService().readUserColor();

    var isAuthenticated = await StorageService().isAuthenticated();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none && isAuthenticated) {
      Response _userData = await UserService().data();
      if (_userData.statusCode == 200) {
        var dataResult = _userData.data;

        var col = _setColor(dataResult['color']?.toString(), storageColor);
        setState(() {
          _readUserColor = col;
        });

        var resultEmail = dataResult['email'];
        var resultVerified = dataResult['verified'];
        if (resultEmail != null) {
          await StorageService().writeEmail(resultEmail);
        }
        if (resultVerified != null) {
          await StorageService().writeVerified(resultVerified.toString());
        }
      } else {
        await StorageService().deleteAuthToken();
        setState(() {
          _readUserColor =
              _setColor(storageColor.value.toString(), storageColor);
        });
      }
    } else {
      setState(() {
        _readUserColor = _setColor(storageColor.value.toString(), storageColor);
      });
    }
  }

  Future<Color> _setColor(String colorResult, Color storageColor) async {
    var serverColor =
        colorResult == null ? Colors.transparent : HexColor(colorResult);

    if (serverColor != storageColor) {
      await StorageService().writeUserColor(serverColor);
      return serverColor;
    } else {
      return storageColor;
    }
  }

  _getApp({Color appBarColor}) {
    return new DynamicTheme(
      key: Key(appBarColor.toString()),
      themeCollection: themeCollection(appBarColor),
      defaultThemeId: 0,
      builder: (context, theme) {
        return new MaterialApp(
          title: 'HepiTrack',
          theme: theme,
          home: HomePage(title: 'HepiTrack'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: FutureBuilder<Color>(
        future: _readUserColor,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getApp(appBarColor: snapshot.data);
          } else {
            return _getApp();
          }
        },
      ),
    );
  }
}
