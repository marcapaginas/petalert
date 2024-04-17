import 'package:flutter/material.dart';
import 'package:pet_clean/services/geolocator.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _value = GeolocatorService.positionStream != null;

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
        } else {
          GeolocatorService.stopBackgroundLocationService();
        }
      },
    );
  }
}
