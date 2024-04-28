import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:pet_clean/models/map_options_state.dart';
import 'package:pet_clean/models/user_location_model.dart';

class MapOptionsCubit extends Cubit<MapOptionsState> {
  MapOptionsCubit() : super(MapOptionsState()) {
    //_loadInitialData();
  }

  // void _loadInitialData() async {
  //   // Cargar los datos de GeoJSON
  //   String geoJsonData =  state.geoJsonData;

  //   // Parsear los datos de GeoJSON
  //   GeoJsonParser parser = GeoJsonParser();
  //   parser.parseGeoJsonAsString(geoJsonData);

  //   // Actualizar el estado con las capas generadas
  //   emit(state.copyWith(
  //     polygons: parser.polygons,
  //     polylines: parser.polylines,
  //     markers: parser.markers,
  //   ));
  // }

  void setUserLocation(UserLocationModel userLocation) {
    emit(state.copyWith(userLocation: userLocation));
  }

  void setOtherUsersLocations(List<UserLocationModel> otherUsersLocations) {
    emit(state.copyWith(otherUsersLocations: otherUsersLocations));
  }

  void setZoom(double zoom) {
    emit(state.copyWith(zoom: zoom));
  }

  void zoomIn() {
    emit(state.copyWith(zoom: state.zoom + 1));
  }

  void zoomOut() {
    emit(state.copyWith(zoom: state.zoom - 1));
  }

  void setMetersRange(double metersRange) {
    emit(state.copyWith(metersRange: metersRange));
  }

  void switchMapStyle() {
    if (state.mapStyle == 'mapbox/streets-v11') {
      emit(state.copyWith(mapStyle: 'mapbox/satellite-streets-v11'));
    } else {
      emit(state.copyWith(mapStyle: 'mapbox/streets-v11'));
    }
  }

  void switchWalking() {
    emit(state.copyWith(walking: !state.walking));
  }
}
