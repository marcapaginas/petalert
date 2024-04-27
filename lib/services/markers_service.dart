// create a service that check for markers in the mongodb database each 2 seconds

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/markers_cubit_singleton.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/marker_model.dart';

class MarkersService {
  static Future<void> checkForMarkers(
      {required double lat, required double lon, required double range}) async {
    while (true) {
      MongoDatabase.getMarkers(lat: lat, lon: lon, range: range)
          .then((markers) {
        MarkersCubitSingleton().markersCubit.clearMarkers();
        for (var markerFound in markers) {
          MarkersCubitSingleton().markersCubit.addMarker(markerFound);
        }
      });
    }
  }
}
