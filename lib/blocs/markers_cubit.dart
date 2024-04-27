import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/marker_model.dart';
import 'package:pet_clean/services/markers_service.dart';

class MarkersCubit extends Cubit<List<MarkerModel>> {
  MarkersCubit() : super([]);

  // void _loadInitialMarkers() async {
  //   final markers = await MongoDatabase.getMarkers();
  //   emit(markers);
  // }

  void addMarker(MarkerModel marker) {
    state.add(marker);
    emit(state);
    //log('Marker added: $marker');
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
