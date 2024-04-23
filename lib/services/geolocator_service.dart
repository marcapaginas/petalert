import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  static StreamSubscription<Position>? positionSubscription;
  static bool? serviceEnabled;
  static LocationPermission? permission;

  // getters
  static bool? get isServiceEnabled => serviceEnabled;
  static LocationPermission? get locationPermission => permission;
  static StreamSubscription<Position>? get positionStream =>
      positionSubscription;

  static LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    //forceLocationManager: true,
    // intervalDuration: const Duration(seconds: 2),
    // foregroundNotificationConfig: const ForegroundNotificationConfig(
    //   notificationText: "La aplicación está ejecutándose en segundo plano.",
    //   notificationTitle: "Corriendo en segundo plano",
    //   enableWakeLock: true,
    // ),
  );

  static void checkServiceAndPermission() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled!) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  static startBackgroundLocationService() {
    //checkServiceAndPermission();
    positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      //todo: add logic to save the position in the database
    });
  }

  static stopBackgroundLocationService() {
    positionSubscription?.cancel();
  }
}
