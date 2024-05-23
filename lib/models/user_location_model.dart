import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserLocationModel {
  final String userId;
  final double latitude;
  final double longitude;
  final int? lastUpdate;

  UserLocationModel(
      {required this.userId,
      required this.latitude,
      required this.longitude,
      this.lastUpdate});

  @override
  String toString() {
    return 'UserLocationModel{user: $userId, latitude: $latitude, longitude: $longitude}';
  }

  UserLocationModel copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    int? lastUpdate,
  }) {
    return UserLocationModel(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  setLatLng(LatLng latLng) {
    return copyWith(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  get marker {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(latitude, longitude),
      child: const Icon(
        Icons.location_on,
        size: 80,
        color: Colors.red,
      ),
    );
  }

  get markerGeoJson {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'properties': {
        'userId': userId,
      },
    };
  }
}
