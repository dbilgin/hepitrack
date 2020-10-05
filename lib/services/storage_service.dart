import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final storage = new FlutterSecureStorage();

  Future<void> addTrackData(String trackData) async {
    var currentData = await storage.read(key: 'track');
    var separator = '';
    if (currentData != null && currentData.length > 0) {
      separator = ',';
    }

    var dataToWrite = (currentData ?? '') + separator + json.encode(trackData);
    await storage.write(key: 'track', value: dataToWrite);
  }

  Future<List<dynamic>> readTrackData() async {
    var currentData = '[' + ((await storage.read(key: 'track')) ?? '') + ']';
    return jsonDecode(currentData);
  }

  Future<bool> isAuthenticated() async {
    return await readAuthToken() != null;
  }

  Future<void> writeUserData(String authToken, String email) async {
    await writeAuthToken(authToken);
    await writeEmail(email);
  }

  Future<void> writeAuthToken(String value) async {
    await storage.write(key: 'auth_token', value: value);
  }

  Future<void> deleteAuthToken() async {
    await storage.delete(key: 'auth_token');
  }

  Future<String> readAuthToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> writeEmail(String value) async {
    await storage.write(key: 'email', value: value);
  }

  Future<String> readEmail() async {
    return await storage.read(key: 'email');
  }

  Future<void> writeVerified(String value) async {
    await storage.write(key: 'verified', value: value);
  }

  Future<String> readVerified() async {
    return await storage.read(key: 'verified');
  }

  Future<void> writeUserColor(Color value) async {
    await storage.write(key: 'user_color', value: value.value.toString());
  }

  Future<void> deleteUserColor() async {
    await storage.delete(key: 'user_color');
  }

  Future<Color> readUserColor() async {
    var numberStr = await storage.read(key: 'user_color');
    if (numberStr == null) return Colors.transparent;

    return Color(int.parse(numberStr));
  }

  Future<void> deleteAll() async {
    storage.deleteAll();
  }
}
