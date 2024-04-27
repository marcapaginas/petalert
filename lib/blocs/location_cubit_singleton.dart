import 'package:pet_clean/blocs/location_cubit.dart';

class LocationCubitSingleton {
  static final LocationCubitSingleton _singleton =
      LocationCubitSingleton._internal();

  factory LocationCubitSingleton() {
    return _singleton;
  }

  LocationCubitSingleton._internal();

  final LocationCubit locationCubit = LocationCubit();
}
