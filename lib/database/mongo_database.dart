import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:pet_clean/blocs/location_cubit_singleton.dart';
import 'package:pet_clean/blocs/map_options_cubit_singleton.dart';
import 'package:pet_clean/models/marker_model.dart';

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

  // get all markers
  static Future<List<MarkerModel>> getMarkers(
      {required double lat, required double lon, required double range}) async {
    try {
      if (db == null) {
        await connect();
      }
      List<MarkerModel> recoveredMarkers = [];

      log(' getmarkers en mongodatabaes: lat: $lat, lon: $lon, range: $range');

      // parece estar descentrado, obtiene marcadores que no estan en el circulo
      // var findParameters = {
      //   'location': {
      //     '\$near': {
      //       '\$geometry': {
      //         'type': '"Point"',
      //         'coordinates': [lon, lat]
      //       },
      //       '\$maxDistance': 115,
      //     },
      //   },
      // };

      var findParameters = {
        'longlat': {
          '\$near': [lon, lat],
          '\$maxDistance': range / 100000
        }
      };

      var query = db!.collection('markers').find(findParameters);

      List<Map<String, dynamic>> records = await query.toList();

      // funciona pero no se pq hay que dividir los metros por 100000

      // var query = db!.collection('markers').find({
      //   'longlat': {
      //     '\$near': [lon, lat],
      //     '\$maxDistance': range / 100000
      //   }
      // });

      // var query = db!.collection('markers').find({
      //   'location': {
      //     '\$near': {
      //       '\$geometry': {
      //         'type': 'Point',
      //         'coordinates': [lon, lat]
      //       },
      //       '\$maxDistance': range * 1
      //     }
      //   }
      // });

      // var query = db!.collection('markers').find({
      //   'location': {
      //     '\$near': {
      //       '\$geometry': {
      //         'type': 'Point',
      //         'coordinates': [lon, lat]
      //       },
      //       '\$maxDistance': range,
      //     }
      //   }
      // });

      // var query = db!.collection('markers').find({
      //   'location': {
      //     '\$geoWithin': {
      //       '\$centerSphere': [
      //         [lon, lat],
      //         (range / 1000) / 6378.1
      //       ]
      //     }
      //   }
      // });

      //List<Map<String, dynamic>> records = await query.toList();

      // var query = db!.collection('markers').find({
      //   'location': {
      //     '\$near': {
      //       '\$geometry': {
      //         'type': 'Point',
      //         'coordinates': [lat, lon]
      //       },
      //       '\$maxDistance': range,
      //     }
      //   }
      // });
      //var query = db!.collection('markers').find();
      //var records = await query.toList();

      log('marcadores devueltos por la query: ${records.length}');

      for (var record in records) {
        recoveredMarkers.add(MarkerModel(
          id: record['userId'].toString(),
          marker: Marker(
            point: LatLng(record['latitude'], record['longitude']),
            child: const Icon(
              Icons.location_on,
              color: Colors.green,
              size: 40,
            ),
          ),
        ));
      }
      return recoveredMarkers;
    } catch (e) {
      log('Error retrieving markers: $e');
      return [];
    }
  }

  // db.tuColeccion.find({
  //   location: {
  //     $near: {
  //       $geometry: {
  //         type: "Point",
  //         coordinates: [-1.2068705, 37.9723167]
  //       },
  //       $maxDistance: 50
  //     }
  //   }
  // })
}
