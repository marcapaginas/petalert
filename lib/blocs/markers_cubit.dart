import 'package:bloc/bloc.dart';
import 'package:flutter_map/flutter_map.dart';

class MarkersCubit extends Cubit<List<Marker>> {
  MarkersCubit() : super([]);

  void addMarker(Marker marker) {
    state.add(marker);
    emit(state);
  }

  void removeMarker(Marker marker) {
    state.remove(marker);
    emit(state);
  }
}
