import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/pages/alerts.dart';
import 'package:pet_clean/pages/first_page.dart';
import 'package:pet_clean/pages/map_page.dart';
import 'package:pet_clean/pages/settings.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/services/markers_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // late LocationSettings locationSettings = AndroidSettings(
  //   accuracy: LocationAccuracy.high,
  //   distanceFilter: 5,
  //   intervalDuration: const Duration(seconds: 2),
  //   // foregroundNotificationConfig: const ForegroundNotificationConfig(
  //   //   notificationText: "La aplicación está ejecutándose en segundo plano.",
  //   //   notificationTitle: "Corriendo en segundo plano",
  //   //   enableWakeLock: true,
  //   //   color: Colors.green,
  //   // ),
  // );

  @override
  void initState() {
    super.initState();
    // Geolocator.getCurrentPosition().then((Position position) {
    //   _actionsWithPosition(position);
    // });
    GeolocatorService.startBackgroundLocationService(foreground: true);
    _listenToPositionStream();
  }

  void _listenToPositionStream() {
    Geolocator.getPositionStream().listen((Position position) {
      _actionsWithPosition(position);
    });
  }

  void _actionsWithPosition(Position position) async {
    log(position.toString());
    setState(() {
      context
          .read<LocationCubit>()
          .setLocation(LatLng(position.latitude, position.longitude));
    });
    if (context.read<MapOptionsCubit>().state.walking) {
      MongoDatabase.insert({
        'userId': supabase.auth.currentUser!.id,
        'longlat': [position.longitude, position.latitude],
        'location': {
          'type': 'Point',
          'coordinates': [position.longitude, position.latitude]
        },
        'latitude': position.latitude,
        'longitude': position.longitude,
        'date': DateTime.now().toIso8601String(),
      });
      //log('almacenado: Location: ${position.longitude}, ${position.latitude}');
    } else {
      log('Not walking');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetAlert',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.black,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          Container(
            color: Colors.green,
            child: const FirstPage(),
          ),
          Container(
            color: Colors.green,
            child: const MapPage(),
          ),
          Container(
            color: Colors.green,
            child: const Alerts(),
          ),
          Container(
            color: Colors.green,
            child: const Center(
              child: Settings(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AlertsCubit, List<AlertModel>>(
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.black12],
                begin: Alignment.topCenter,
                end: Alignment(0, -0.8),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              onDestinationSelected: _onItemTapped,
              indicatorColor: Colors.greenAccent,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _selectedIndex,
              destinations: <NavigationDestination>[
                const NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Inicio',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                NavigationDestination(
                  icon: state.isNotEmpty
                      ? Badge(
                          label: Text(state.length.toString()),
                          child: const Icon(Icons.notifications_sharp))
                      : const Icon(Icons.notifications_none),
                  label: 'Alertas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Opciones',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
