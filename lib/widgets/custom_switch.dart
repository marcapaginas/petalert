import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/services/geolocator_service.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _value = GeolocatorService.positionStream != null;
  StreamSubscription<Position>? _positionStreamSubscription;
  late LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    intervalDuration: const Duration(seconds: 2),
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationText: "La aplicación está ejecutándose en segundo plano.",
      notificationTitle: "Corriendo en segundo plano",
      enableWakeLock: true,
      color: Colors.green,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      activeColor: Colors.green,
      onChanged: (bool value) {
        setState(() {
          _value = value;
        });
        if (value) {
          GeolocatorService.startBackgroundLocationService();
          _listenToPositionStream();
        } else {
          GeolocatorService.stopBackgroundLocationService();
          _positionStreamSubscription?.cancel();
        }
      },
    );
  }

  void _listenToPositionStream() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _actionsWithPosition(position);
    });
  }

  void _actionsWithPosition(Position position) async {
    setState(() {
      context
          .read<LocationCubit>()
          .setLocation(LatLng(position.latitude, position.longitude));
    });
  }
}
