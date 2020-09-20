import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Common {
  static bool isValidEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(value);
  }

  static cleanAndRestart(BuildContext context) async {
    await StorageService().deleteAll();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    Phoenix.rebirth(context);
  }

  static ThemeData getThemeData({
    @required Brightness brightness,
    Color appBarColor,
  }) {
    MaterialColor mainColor = brightness == Brightness.light
        ? Colors.blueGrey ?? '#607d8b'
        : Colors.green;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? Colors.white : null,
      buttonColor: mainColor,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        buttonColor: mainColor,
        textTheme: ButtonTextTheme.primary,
        height: 50,
      ),
      appBarTheme: AppBarTheme(
        color: appBarColor ?? Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: mainColor,
        ),
      ),
      backgroundColor: Colors.blue,
      primaryColor: mainColor,
      primarySwatch: mainColor,
      accentColor: Colors.blueAccent,
      primaryTextTheme: TextTheme(
        headline6: TextStyle(color: mainColor),
      ),
      textTheme: TextTheme(
        bodyText1: TextStyle(color: mainColor[700]),
        bodyText2: TextStyle(color: mainColor[700], fontSize: 16),
        headline6: TextStyle(color: mainColor[700]),
        overline: TextStyle(color: mainColor[700]),
      ),
    );
  }
}
