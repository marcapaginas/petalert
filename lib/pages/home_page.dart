import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:pet_clean/pages/alerts.dart';
import 'package:pet_clean/pages/first_page.dart';
import 'package:pet_clean/pages/map_page.dart';
import 'package:pet_clean/pages/settings.dart';
import 'package:pet_clean/services/geolocator_service.dart';
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

  @override
  void initState() {
    super.initState();
    // Geolocator.getCurrentPosition().then((Position position) {
    //   _actionsWithPosition(position);
    // });
    GeolocatorService.startBackgroundLocationService(foreground: true);
    _searchOtherUsersLocations();
    _listenToPositionStream();
    // load userdata from database
    SupabaseDatabase.getUserData(supabase.auth.currentUser!.id)
        .then((userData) {
      context.read<UserDataCubit>().setUserData(userData);
    });
  }

  void _searchOtherUsersLocations() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (context.read<MapOptionsCubit>().state.userLocation != null) {
        MongoDatabase.searchOtherUsers(
          context.read<MapOptionsCubit>().state.userLocation!.latitude,
          context.read<MapOptionsCubit>().state.userLocation!.longitude,
          context.read<MapOptionsCubit>().state.metersRange,
        ).then((result) {
          context.read<MapOptionsCubit>().setOtherUsersLocations(result);
          context.read<AlertsCubit>().setAlerts(result);
        });
      }
    });
  }

  void _listenToPositionStream() {
    Geolocator.getPositionStream().listen((Position position) {
      _actionsWithPosition(position);
    });
  }

  void _actionsWithPosition(Position position) async {
    log(position.toString());
    setState(() {
      context.read<MapOptionsCubit>().setUserLocation(UserLocationModel(
          user: supabase.auth.currentUser!,
          userId: supabase.auth.currentUser!.id,
          email: supabase.auth.currentUser!.email,
          latitude: position.latitude,
          longitude: position.longitude));
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
            child: FirstPage(),
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
                  icon: state.where((alert) => !alert.isDiscarded).isNotEmpty
                      ? Badge(
                          label: Text(state
                              .where((alert) => !alert.isDiscarded)
                              .length
                              .toString()),
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
