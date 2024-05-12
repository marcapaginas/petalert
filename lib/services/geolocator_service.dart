import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  static GeolocatorService? _instance;

  GeolocatorService._();

  factory GeolocatorService() {
    _instance ??= GeolocatorService._();
    return _instance!;
  }

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
  );

  static LocationSettings locationSettingsForeground = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    intervalDuration: const Duration(seconds: 2),
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationIcon:
          AndroidResource(name: 'ic_stat_dog_running', defType: 'mipmap'),
      notificationText: "La aplicación está ejecutándose en segundo plano.",
      notificationTitle: "Corriendo en segundo plano",
      enableWakeLock: true,
    ),
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

  static Stream<Position> startBackgroundLocationService(
      {bool foreground = false}) {
    checkServiceAndPermission();

    Stream<Position> position = Geolocator.getPositionStream(
        locationSettings:
            foreground ? locationSettingsForeground : locationSettings);

    return position;
  }

  static Future<void> stopBackgroundLocationService() async {
    await positionSubscription?.cancel();
    return Future.value();
  }
}
