import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:pet_clean/classes/custom_geo_json_parser.dart';
import 'package:pet_clean/models/user_location_model.dart';

class MapOptionsState {
  final double zoom;
  final double metersRange;
  final String mapStyle;
  final bool walking;

  UserLocationModel? userLocation;
  List<UserLocationModel>? otherUsersLocations;

  List<Marker>? markers;
  List<CircleMarker>? circles;

  MapOptionsState({
    this.zoom = 18.5,
    this.metersRange = 50.0,
    this.mapStyle = 'mapbox/streets-v11',
    this.walking = false,
    this.userLocation,
    this.otherUsersLocations,
    this.markers,
    this.circles,
  });

  MapOptionsState copyWith({
    double? zoom,
    double? metersRange,
    String? mapStyle,
    bool? walking,
    UserLocationModel? userLocation,
    List<UserLocationModel>? otherUsersLocations,
    List<Marker>? markers,
    List<CircleMarker>? circles,
  }) {
    parseGeoJsonData(geoJsonData);
    return MapOptionsState(
      zoom: zoom ?? this.zoom,
      metersRange: metersRange ?? this.metersRange,
      mapStyle: mapStyle ?? this.mapStyle,
      walking: walking ?? this.walking,
      userLocation: userLocation ?? this.userLocation,
      otherUsersLocations: otherUsersLocations ?? this.otherUsersLocations,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
    );
  }

  @override
  String toString() {
    return 'MapOptionsState{zoom: $zoom, metersRange: $metersRange, mapStyle: $mapStyle, walking: $walking, userLocation: $userLocation, otherUsersLocations: $otherUsersLocations}';
  }

  String get geoJsonData {
    List<Map<String, dynamic>> features = [];
    if (userLocation != null) {
      features.add(userLocation!.markerGeoJson);
    }
    if (otherUsersLocations != null) {
      for (var userLocation in otherUsersLocations!) {
        features.add(userLocation.markerGeoJson);
      }
    }
    if (userLocation != null) {
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Circle',
          'coordinates': [userLocation!.longitude, userLocation!.latitude],
        },
        'properties': {
          'radius': metersRange,
        },
      });
    }

    var json = jsonEncode({
      'type': 'FeatureCollection',
      'features': features,
    });

    //log('geoJsonData: $json');

    return json;
  }

  // clear user location
  void clearUserLocation() {
    userLocation = null;
  }

  // clear other users locations
  void clearOtherUsersLocations() {
    otherUsersLocations = null;
  }

  // clear markers
  void clearMarkers() {
    markers = null;
  }

  // parse geojson data
  void parseGeoJsonData(String geoJsonData) {
    GeoJsonParser parser = CustomGeoJsonParser();
    parser.setDefaultCircleMarkerColor =
        const Color.fromARGB(81, 215, 203, 137);
    parser.setDefaultMarkerTapCallback((f) => log('Marker tapped: $f'));
    parser.parseGeoJsonAsString(geoJsonData);
    markers = parser.markers;
    circles = parser.circles;
  }
}
