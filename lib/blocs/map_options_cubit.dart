import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/models/map_options_model.dart';
import 'package:pet_clean/models/user_location_model.dart';

class MapOptionsCubit extends Cubit<MapOptionsState> {
  static final MapOptionsCubit _singleton = MapOptionsCubit._internal();

  factory MapOptionsCubit() {
    return _singleton;
  }

  MapOptionsCubit._internal() : super(MapOptionsState());

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
    emit(state.copyWith(zoom: state.zoom + 0.5));
  }

  void zoomOut() {
    emit(state.copyWith(zoom: state.zoom - 0.5));
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
}
