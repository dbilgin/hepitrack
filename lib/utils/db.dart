import 'package:hepitrack/models/body_part.dart';
import 'package:hepitrack/models/symptom.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

class DB {
  static Future<Database> _database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'hepitrack.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE symptoms(id INTEGER PRIMARY KEY, name TEXT, image TEXT, default_body_part INTEGER)",
        );
        await db.execute(
          "CREATE TABLE body_parts(id INTEGER PRIMARY KEY, name TEXT)",
        );

        Constants.allSymptoms.forEach((Symptom symptom) async {
          await db.insert(
            'symptoms',
            symptom.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });

        Constants.partList.forEach((BodyPart bodyPart) async {
          await db.insert(
            'body_parts',
            bodyPart.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      },
      version: 1,
    );
  }

  static Future<List<Symptom>> symptoms() async {
    final Database db = await _database();
    final List<Map<String, dynamic>> maps = await db.query('symptoms');
    return List.generate(maps.length, (i) {
      return Symptom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        image: maps[i]['image'],
        defaultBodyPart: maps[i]['default_body_part'],
      );
    });
  }

  static Future<Symptom> symptom(int id) async {
    final Database db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(
      'symptoms',
      where: "id = ?",
      whereArgs: [id],
    );
    return Symptom(
      id: maps.first['id'],
      name: maps.first['name'],
      image: maps.first['image'],
      defaultBodyPart: maps.first['default_body_part'],
    );
  }

  static Future<List<BodyPart>> bodyParts() async {
    final Database db = await _database();
    final List<Map<String, dynamic>> maps = await db.query('body_parts');
    return List.generate(maps.length, (i) {
      return BodyPart(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }
}
