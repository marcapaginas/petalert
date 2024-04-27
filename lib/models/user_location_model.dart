import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLocationModel {
  final User user;
  final double latitude;
  final double longitude;

  UserLocationModel(
      {required this.user, required this.latitude, required this.longitude});

  @override
  String toString() {
    return 'UserLocationModel{user: $user, latitude: $latitude, longitude: $longitude}';
  }

  UserLocationModel copyWith({
    User? user,
    double? latitude,
    double? longitude,
  }) {
    return UserLocationModel(
      user: user ?? this.user,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
        size: 30,
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
        'title': user.id,
        'description': user.email,
      },
    };
  }
}
