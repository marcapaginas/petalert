import 'package:pet_clean/blocs/markers_cubit.dart';

class MarkersCubitSingleton {
  static final MarkersCubitSingleton _singleton =
      MarkersCubitSingleton._internal();

  factory MarkersCubitSingleton() {
    return _singleton;
  }

  MarkersCubitSingleton._internal();

  final MarkersCubit markersCubit = MarkersCubit();
}
