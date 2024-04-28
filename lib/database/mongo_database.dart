import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MongoDatabase {
  static MongoDatabase? _instance;

  // private constructor
  MongoDatabase._();

  // Factory constructor to return the same instance
  factory MongoDatabase() {
    _instance ??= MongoDatabase._();
    return _instance!;
  }

  static Db? db;

  /// Connects to the MongoDB database.
  static Future<void> connect() async {
    try {
      await dotenv.load();

      db = await Db.create(dotenv.env['MONGO_CONNECTION_STRING']!);
      await db!.open();

      //log('Connected to MongoDB');
    } catch (e) {
      log('Error connecting to MongoDB: $e');
    }
  }

  /// Closes the connection to the MongoDB database.
  static void close() {
    db?.close();
    log('Connection to MongoDB closed');
  }

  /// Inserts or updates data into the 'markers' collection.
  static Future<void> insert(Map<String, dynamic> data) async {
    try {
      if (db == null) {
        await connect();
      }
      await db!.collection('markers').update(
        {'userId': data['userId']}, // Filtro de consulta
        data, // Datos a insertar o actualizar
        upsert: true, // Crea un nuevo documento si no se encuentra ninguno
      );
      //log('Data inserted: $data');
    } catch (e) {
      log('Error inserting data: $e');
    }
  }

  // get all other users as user location models
  static Future<List<UserLocationModel>> searchOtherUsers(
      double lat, double lon, double range) async {
    try {
      if (db == null) {
        await connect();
      }

      String? userId = Supabase.instance.client.auth.currentUser?.id;
      List<UserLocationModel> otherUsersFound = [];

      var findParameters = {
        'longlat': {
          '\$near': [lon, lat],
          '\$maxDistance': range / 100000
        },
        'userId': {'\$ne': userId},
      };

      var query = db!.collection('markers').find(findParameters);

      List<Map<String, dynamic>> records = await query.toList();

      log('otros usuarios devueltos por la query: ${records.length}');

      for (var record in records) {
        otherUsersFound.add(UserLocationModel(
          userId: record['userId'].toString(),
          latitude: record['latitude'],
          longitude: record['longitude'],
        ));
      }
      return otherUsersFound;
    } catch (e) {
      log('Error retrieving markers: $e');
      return [];
    }
  }
}
