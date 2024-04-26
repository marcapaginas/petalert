import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MarkerModel {
  final String id;
  final String nombre;
  final Marker marker;

  MarkerModel({
    required this.id,
    required this.nombre,
    required this.marker,
  });
}
