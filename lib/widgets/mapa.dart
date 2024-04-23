import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/markers_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> with TickerProviderStateMixin {
  final _mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  final _mapboxStyle_satellite = 'mapbox/satellite-streets-v12';
  final _mapboxStyle_petalert = 'josemiguel/cluz800ct005g01qvc40k523n';
  var _mapboxStyle = 'josemiguel/cluz800ct005g01qvc40k523n';

  late final _animatedMapController = AnimatedMapController(vsync: this);

  LatLng _currentPosition = const LatLng(0, 0);
  final double _zoom = 19;

  @override
  void initState() {
    super.initState();
    dotenv.load();
    _getCurrentPosition();
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

    return Scaffold(
        body: FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: locationCubit.state,
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
                  point: locationCubit.state,
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
                  point: locationCubit.state,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _mapboxStyle == _mapboxStyle_satellite
                  ? _mapboxStyle = _mapboxStyle_petalert
                  : _mapboxStyle = _mapboxStyle_satellite;
            });
          },
          child: const Icon(Icons.layers_outlined),
        ));
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
      // update or insert marker data to mongo
      // MongoDatabase.insert({
      //   'userId': supabase.auth.currentUser!.id,
      //   'location': 'POINT(${state.longitude} ${state.latitude})',
      //   'date': DateTime.now().toIso8601String(),
      // });

      // log coordinates
      log('listen to cubit: Location: ${state.longitude}, ${state.latitude}');
      //check if widget is mounted
      if (mounted) {
        _animatedMapController.animateTo(dest: state);
      } else {
        return;
      }
    });
  }
}
