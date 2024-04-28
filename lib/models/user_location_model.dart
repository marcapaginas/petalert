import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLocationModel {
  final User? user;
  final String? userId;
  final String? email;
  final double latitude;
  final double longitude;

  UserLocationModel(
      {this.user,
      this.userId,
      this.email,
      required this.latitude,
      required this.longitude});

  @override
  String toString() {
    return 'UserLocationModel{user: ${user?.id}, ${user?.email}, latitude: $latitude, longitude: $longitude}';
  }

  UserLocationModel copyWith({
    User? user,
    String? userId,
    String? email,
    double? latitude,
    double? longitude,
  }) {
    return UserLocationModel(
      user: user ?? this.user,
      userId: userId ?? this.userId,
      email: email ?? this.email,
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
        'title': user?.id ?? 'Unknown',
        'description': user?.email ?? 'Unknown',
      },
    };
  }
}
