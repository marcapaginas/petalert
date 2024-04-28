import 'package:bloc/bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_clean/models/marker_model.dart';

class MarkersCubit extends Cubit<List<MarkerModel>> {
  MarkersCubit() : super([]);

  void addMarker(MarkerModel marker) {
    state.add(marker);
    emit(state);
  }

  void removeMarker(MarkerModel marker) {
    state.remove(marker);
    emit(state);
  }

  void clearMarkers() {
    state.clear();
    emit(state);
  }

  List<Marker> get markers {
    return state.map((marker) => marker.marker).toList();
  }
}
