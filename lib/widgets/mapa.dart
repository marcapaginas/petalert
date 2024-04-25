import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/blocs/markers_cubit.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> with TickerProviderStateMixin {
  final _mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  late final _animatedMapController = AnimatedMapController(vsync: this);

  @override
  void initState() {
    super.initState();
    dotenv.load();
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markersCubit = context.watch<MarkersCubit>();
    final locationCubit = context.watch<LocationCubit>();
    final mapOptionsCubit = context.watch<MapOptionsCubit>();

    // StreamSubscription<Position>? positionSubscription;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: locationCubit.state,
              initialZoom: mapOptionsCubit.state.zoom,
              onMapReady: () {
                // positionSubscription =
                //     GeolocatorService.startBackgroundLocationService(
                //             foreground: false)
                //         .listen((event) {
                //   locationCubit
                //       .setLocation(LatLng(event.latitude, event.longitude));
                // });
                _listenToLocationCubit();
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/${mapOptionsCubit.state.mapStyle}/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken',
                // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: locationCubit.state,
                    radius: mapOptionsCubit.state.metersRange,
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
                    point: locationCubit.state,
                    width: 80,
                    height: 80,
                    rotate: true,
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
          Positioned(
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Text(
                    'Metros: ${mapOptionsCubit.state.metersRange.toStringAsFixed(0)}',
                    textAlign: TextAlign.end,
                  ),
                  Slider(
                    value: mapOptionsCubit.state.metersRange,
                    min: 5.0,
                    max: 100.0,
                    onChanged: (newValue) {
                      mapOptionsCubit.setMetersRange(newValue);
                    },
                  ),
                  Switch(
                    value: mapOptionsCubit.state.walking,
                    onChanged: (value) {
                      mapOptionsCubit.switchWalking();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.lightBlue.shade50,
            onPressed: () {
              mapOptionsCubit.zoomIn();
              _animatedMapController.animatedZoomIn();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.lightBlue.shade50,
            onPressed: () {
              mapOptionsCubit.zoomOut();
              _animatedMapController.animatedZoomOut();
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: mapOptionsCubit.switchMapStyle,
            child: const Icon(Icons.layers_outlined),
          ),
        ],
      ),
    );
  }

  //listen to cubit changes
  void _listenToLocationCubit() {
    context.read<LocationCubit>().stream.listen((LatLng state) {
      try {
        if (mounted) {
          _animatedMapController.animateTo(dest: state);
        } else {
          return;
        }
      } catch (e) {
        log('Error escuchando al cubit: $e');
      }
    });
  }
}
