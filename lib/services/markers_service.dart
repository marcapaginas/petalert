// create a service that check for markers in the mongodb database each 2 seconds

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/markers_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/marker_model.dart';

class MarkersService {
  MarkersService(MarkersCubit markersCubit) : _markersCubit = markersCubit;

  final MarkersCubit _markersCubit;

  static Future<void> checkForMarkers() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      MongoDatabase.getRecentMarkers().then((markers) {
        for (var marker in markers) {
          log(marker.toString());
          // _markersCubit.addMarker(MarkerModel(
          //     id: marker['_id'].toString(),
          //     nombre: marker['nombre'],
          //     marker: Marker(
          //       width: 40.0,
          //       height: 40.0,
          //       point: LatLng(marker['location']['coordinates'][1],
          //           marker['location']['coordinates'][0]),
          //       child: Container(
          //         decoration: const BoxDecoration(
          //           color: Colors.red,
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //     )));
        }
      });
    }
  }
}
