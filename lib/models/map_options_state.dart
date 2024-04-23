class MapOptionsState {
  final double zoom;
  final double metersRange;
  final String mapStyle;

  MapOptionsState({
    this.zoom = 19.0,
    this.metersRange = 50.0,
    this.mapStyle = 'mapbox/streets-v11',
  });

  MapOptionsState copyWith({
    double? zoom,
    double? metersRange,
    String? mapStyle,
  }) {
    return MapOptionsState(
      zoom: zoom ?? this.zoom,
      metersRange: metersRange ?? this.metersRange,
      mapStyle: mapStyle ?? this.mapStyle,
    );
  }
}
