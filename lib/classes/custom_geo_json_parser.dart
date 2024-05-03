import 'package:flutter/material.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:pet_clean/database/supabase_database.dart';

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
      child: InkWell(
        splashColor: Colors.amber,
        onTap: () {
          onMarkerTap(properties);
        },
        child: Transform.translate(
          offset: const Offset(-10, -27),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Icon(
              Icons.location_on,
              color: properties['userId'] ==
                      SupabaseDatabase.supabase.auth.currentUser?.id
                  ? Colors.green
                  : defaultMarkerColor,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
