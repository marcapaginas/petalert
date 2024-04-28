import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
// import 'package:flutter_map_geojson/flutter_map_geojson.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
// import 'package:pet_clean/blocs/markers_cubit.dart';
// import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/map_options_state.dart';
import 'package:pet_clean/widgets/walking_switch.dart';
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
    final mapOptionsCubit = context.watch<MapOptionsCubit>();

    //var testGeoJson = mapOptionsCubit.state.geoJsonData;

    //myGeoJson.parseGeoJsonAsString(testGeoJson);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: mapOptionsCubit.state.userLocation!.marker.point,
              initialZoom: mapOptionsCubit.state.zoom,
              onMapReady: () {
                Timer.periodic(const Duration(seconds: 5), (timer) {
                  _searchOtherUsers(
                      lat: mapOptionsCubit.state.userLocation!.latitude,
                      lon: mapOptionsCubit.state.userLocation!.longitude,
                      range: mapOptionsCubit.state.metersRange);
                });
                //_listenToLocationCubit();
                _listenToMapOptionsCubit();
              },
            ),
            children: [
              TileLayer(
                // urlTemplate:
                //     'https://api.mapbox.com/styles/v1/${mapOptionsCubit.state.mapStyle}/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken',
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),

              PolygonLayer(polygons: mapOptionsCubit.state.polygons!),
              PolylineLayer(polylines: mapOptionsCubit.state.polylines!),
              CircleLayer(circles: mapOptionsCubit.state.circles!),
              MarkerLayer(markers: mapOptionsCubit.state.markers!),

              // CircleLayer(
              //   circles: [
              //     CircleMarker(
              //       point: mapOptionsCubit.state.userLocation!.marker.point,
              //       radius: mapOptionsCubit.state.metersRange,
              //       borderColor: Colors.green,
              //       borderStrokeWidth: 1,
              //       useRadiusInMeter: true,
              //       color: const Color.fromRGBO(217, 255, 0, 0.268),
              //     ),
              //   ],
              // ),
              // MarkerLayer(
              //   markers: [
              //     Marker(
              //       point: locationCubit.state,
              //       width: 80,
              //       height: 80,
              //       rotate: true,
              //       alignment: const Alignment(0, -0.65),
              //       child: const Icon(
              //         Icons.location_on,
              //         color: Colors.red,
              //         size: 60,
              //       ),
              //     ),
              //     ...markersCubit.markers,
              //   ],
              // ),
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
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 15,
            left: 15,
            child: WalkingSwitch(),
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
  // void _listenToLocationCubit() {
  //   context.read<LocationCubit>().stream.listen((LatLng state) {
  //     try {
  //       if (mounted) {
  //         _animatedMapController.animateTo(dest: state);
  //       } else {
  //         return;
  //       }
  //     } catch (e) {
  //       log('Error escuchando al cubit: $e');
  //     }
  //   });
  // }

  void _listenToMapOptionsCubit() {
    context.read<MapOptionsCubit>().stream.listen((MapOptionsState state) {
      try {
        if (mounted) {
          _animatedMapController.animateTo(
              dest: state.userLocation!.marker.point);
        } else {
          return;
        }
      } catch (e) {
        log('Error escuchando al cubit: $e');
      }
    });
  }

  void _searchOtherUsers(
      {required double lat, required double lon, required double range}) async {
    MongoDatabase.searchOtherUsers(lat: lat, lon: lon, range: range)
        .then((result) {
      context.read<MapOptionsCubit>().setOtherUsersLocations(result);
    });
  }
}
