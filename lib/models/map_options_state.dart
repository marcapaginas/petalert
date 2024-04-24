class MapOptionsState {
  final double zoom;
  final double metersRange;
  final String mapStyle;
  final bool walking;

  MapOptionsState({
    this.zoom = 18.0,
    this.metersRange = 50.0,
    this.mapStyle = 'mapbox/streets-v11',
    this.walking = false,
  });

  MapOptionsState copyWith({
    double? zoom,
    double? metersRange,
    String? mapStyle,
    bool? walking,
  }) {
    return MapOptionsState(
      zoom: zoom ?? this.zoom,
      metersRange: metersRange ?? this.metersRange,
      mapStyle: mapStyle ?? this.mapStyle,
      walking: walking ?? this.walking,
    );
  }
}
