import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:get/get.dart';
import 'package:pet_clean/classes/custom_geo_json_parser.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/models/user_location_model.dart';

class MapOptionsState {
  final double zoom;
  final double metersRange;
  final String mapStyle;

  UserLocationModel? userLocation;
  List<UserLocationModel>? otherUsersLocations;

  List<Marker>? markers;
  List<CircleMarker>? circles;

  MapOptionsState({
    this.zoom = 18.5,
    this.metersRange = 50.0,
    this.mapStyle = 'mapbox/streets-v11',
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
      userLocation: userLocation ?? this.userLocation,
      otherUsersLocations: otherUsersLocations ?? this.otherUsersLocations,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
    );
  }

  @override
  String toString() {
    return 'MapOptionsState{zoom: $zoom, metersRange: $metersRange, mapStyle: $mapStyle, userLocation: $userLocation, otherUsersLocations: $otherUsersLocations}';
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

    return json;
  }

  void clearUserLocation() {
    userLocation = null;
  }

  void clearOtherUsersLocations() {
    otherUsersLocations = null;
  }

  void clearMarkers() {
    markers = null;
  }

  void parseGeoJsonData(String geoJsonData) {
    GeoJsonParser parser = CustomGeoJsonParser();
    parser.setDefaultCircleMarkerColor =
        const Color.fromARGB(81, 215, 203, 137);
    parser.setDefaultMarkerTapCallback((properties) {
      mostrarDetallesMarcador(properties);
    });
    parser.parseGeoJsonAsString(geoJsonData);
    markers = parser.markers;
    circles = parser.circles;
  }

  Future<dynamic> mostrarDetallesMarcador(
      Map<String, dynamic> properties) async {
    log('properties: $properties');
    UserData userData = await RedisDatabase().getUserData(properties['userId']);

    //filter pets that are being walked
    List<Pet> pets = userData.pets.where((pet) => pet.isBeingWalked).toList();

    return showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text('${userData.nombre} está paseando a: ',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      pets.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var pet in pets)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: const AssetImage(
                                              'assets/pet.jpeg'),
                                          foregroundImage: pet.avatarURL != ''
                                              ? NetworkImage(pet.avatarURL)
                                              : null,
                                          radius: 40,
                                        ),
                                        Text(
                                          pet.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 20),
                              ],
                            )
                          : const Text('No hay mascotas paseando'),
                    ],
                  )),
              Positioned(
                top: -80,
                left: 10,
                child: Image.asset(
                  'assets/petalert-logo.png',
                  height: 100,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
