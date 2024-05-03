import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/models/map_options_model.dart';
import 'package:pet_clean/widgets/walking_switch_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> with TickerProviderStateMixin {
  //final _mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
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

    return mapOptionsCubit.state.userLocation == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _animatedMapController.mapController,
                  options: MapOptions(
                    initialCenter:
                        mapOptionsCubit.state.userLocation!.marker.point,
                    initialZoom: mapOptionsCubit.state.zoom,
                    onMapReady: () {
                      _listenToMapOptionsCubit();
                    },
                  ),
                  children: [
                    TileLayer(
                      // urlTemplate:
                      //     'https://api.mapbox.com/styles/v1/${mapOptionsCubit.state.mapStyle}/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken',
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    CircleLayer(circles: mapOptionsCubit.state.circles!),
                    MarkerLayer(markers: mapOptionsCubit.state.markers!),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: Text('© OpenStreetMap',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: IntrinsicWidth(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      margin: const EdgeInsets.only(top: 30),
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
}
