import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/markers_cubit.dart';

const _mapboxAccessToken =
    'pk.eyJ1Ijoiam9zZW1pZ3VlbCIsImEiOiJjbHV0cjkzdnUwMGE2MmxwajUycnlwcnY2In0.T_fIrbCR3_ir--RLFHYWxQ';
//const _mapboxStyle = 'mapbox/satellite-streets-v12';
const _mapboxStyle = 'josemiguel/cluz800ct005g01qvc40k523n';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(vsync: this);

  LatLng _currentPosition = const LatLng(0, 0);
  double _zoom = 19;

  @override
  void initState() {
    super.initState();
    //_getCurrentPosition();
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationCubit = context.watch<LocationCubit>();
    final markersCubit = context.watch<MarkersCubit>();

    return Scaffold(
      body: _currentPosition == const LatLng(0, 0)
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Obteniendo posición...'),
                ],
              ),
            )
          : FlutterMap(
              mapController: _animatedMapController.mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: _zoom,
                onMapReady: () {
                  _listenToLocationCubit();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/$_mapboxStyle/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPosition,
                      radius: 30,
                      borderColor: Colors.green,
                      borderStrokeWidth: 1,
                      useRadiusInMeter: true,
                      color: const Color.fromRGBO(217, 255, 0, 0.268),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 80,
                      height: 80,
                      alignment: const Alignment(0, -0.65),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                    ...markersCubit.state,
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  //listen to cubit changes
  void _listenToLocationCubit() {
    context.read<LocationCubit>().stream.listen((LatLng state) {
      setState(() {
        _currentPosition = state;
      });
      _animatedMapController.animateTo(dest: _currentPosition);
    });
  }
}
