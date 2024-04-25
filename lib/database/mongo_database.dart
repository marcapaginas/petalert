import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

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

  /// Retrieves all markers with a date within the last 5 seconds.
  static Future<List<Map<String, dynamic>>> getRecentMarkers() async {
    try {
      if (db == null) {
        await connect();
      }

      // Calculate the date 5 seconds ago
      var now = DateTime.now();
      var fiveSecondsAgo = now.subtract(const Duration(seconds: 5));

      // Format the date to match MongoDB's format
      var formattedDate = fiveSecondsAgo.toIso8601String();

      // Construct the query
      var query = {
        'date': {'\$lte': formattedDate}
      };

      // Perform the query and return the results
      var cursor = db!.collection('markers').find(query);
      var markers = await cursor.toList();
      return markers.map((marker) => marker).toList();
    } catch (e) {
      log('Error retrieving recent markers: $e');
      return [];
    }
  }
}
