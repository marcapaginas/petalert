import 'package:flutter/material.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

class CustomGeoJsonParser extends GeoJsonParser {
  @override
  set setDefaultCircleMarkerColor(Color color) {
    defaultCircleMarkerColor = color;
  }

  @override
  Widget defaultTappableMarker(Map<String, dynamic> properties,
      void Function(Map<String, dynamic>) onMarkerTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onMarkerTap(properties);
        },
        child: Transform.translate(
          offset: const Offset(-5, -20),
          child: Icon(
            Icons.location_on,
            color: properties['description'] == 'correo@josemiguel.net'
                ? Colors.amber
                : defaultMarkerColor,
            size: 40,
          ),
        ),
      ),
    );
  }
}
