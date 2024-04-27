import 'package:pet_clean/models/user_location_model.dart';

class MapOptionsState {
  final double zoom;
  final double metersRange;
  final String mapStyle;
  final bool walking;

  UserLocationModel? userLocation;
  List<UserLocationModel>? otherUsersLocations;

  MapOptionsState({
    this.zoom = 18.0,
    this.metersRange = 50.0,
    this.mapStyle = 'mapbox/streets-v11',
    this.walking = false,
    this.userLocation,
    this.otherUsersLocations,
  });

  MapOptionsState copyWith({
    double? zoom,
    double? metersRange,
    String? mapStyle,
    bool? walking,
    UserLocationModel? userLocation,
    List<UserLocationModel>? otherUsersLocations,
  }) {
    return MapOptionsState(
      zoom: zoom ?? this.zoom,
      metersRange: metersRange ?? this.metersRange,
      mapStyle: mapStyle ?? this.mapStyle,
      walking: walking ?? this.walking,
      userLocation: userLocation ?? this.userLocation,
      otherUsersLocations: otherUsersLocations ?? this.otherUsersLocations,
    );
  }

  @override
  String toString() {
    return 'MapOptionsState{zoom: $zoom, metersRange: $metersRange, mapStyle: $mapStyle, walking: $walking, userLocation: $userLocation, otherUsersLocations: $otherUsersLocations}';
  }

  get geoJsonData {
    List<Map<String, dynamic>> features = [];
    if (userLocation != null) {
      features.add(userLocation!.markerGeoJson);
    }
    if (otherUsersLocations != null) {
      for (var userLocation in otherUsersLocations!) {
        features.add(userLocation.markerGeoJson);
      }
    }
    return {
      'type': 'FeatureCollection',
      'features': features,
    };
  }
}
