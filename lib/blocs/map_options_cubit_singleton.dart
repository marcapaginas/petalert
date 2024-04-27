import 'package:pet_clean/blocs/map_options_cubit.dart';

class MapOptionsCubitSingleton {
  static final MapOptionsCubitSingleton _singleton =
      MapOptionsCubitSingleton._internal();

  factory MapOptionsCubitSingleton() {
    return _singleton;
  }

  MapOptionsCubitSingleton._internal();

  final MapOptionsCubit mapOptionsCubit = MapOptionsCubit();
}
