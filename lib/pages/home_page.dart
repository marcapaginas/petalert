import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:pet_clean/pages/account_page.dart';
import 'package:pet_clean/pages/alerts_page.dart';
import 'package:pet_clean/pages/first_page.dart';
import 'package:pet_clean/pages/map_page.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/widgets/walking_switch_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userId = supabase.auth.currentUser!.id;
  Timer? _timerCheckOtherUsersLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  final int _minutes = 5;

  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  //late final mapOptionsCubit = context.watch<MapOptionsCubit>();

  @override
  void initState() {
    super.initState();
    try {
      _getUserData();
      GeolocatorService.startBackgroundLocationService(foreground: true);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleWalkingState();
  }

  void _handleWalkingState() {
    final walkingCubit = context.watch<WalkingCubit>();

    if (walkingCubit.state) {
      log('Walking');
      if (_positionStreamSubscription == null) {
        log('activating position stream');
        _listenToPositionStream();
      } else {
        log('resuming position stream');
        _positionStreamSubscription?.resume();
      }
      if (_timerCheckOtherUsersLocation == null) {
        _searchOtherUsersLocations();
      }
    } else {
      log('Not walking');
      log('deactivating position stream');
      _stopListeningToPositionStream();
      _stopSearchingOtherUsersLocations();
    }
  }

  @override
  void dispose() {
    GeolocatorService.stopBackgroundLocationService();
    _positionStreamSubscription?.cancel();
    _timerCheckOtherUsersLocation?.cancel();
    super.dispose();
  }

  void _getUserData() async {
    try {
      final userDataCubit = context.read<UserDataCubit>();
      await RedisDatabase()
          .getUserData(userId)
          .then((data) => userDataCubit.setUserData(data));
    } catch (e) {
      log('Error getting user data: $e');
    }
  }

  void _searchOtherUsersLocations() {
    try {
      _timerCheckOtherUsersLocation =
          Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          final mapOptionsCubit = context.read<MapOptionsCubit>();
          final alertsCubit = context.read<AlertsCubit>();
          final userLocation = mapOptionsCubit.state.userLocation;
          final radius = mapOptionsCubit.state.metersRange;
          if (userLocation != null) {
            // RedisDatabase()
            //     .getUserLocationsByDistance(
            //         userLocation.longitude, userLocation.latitude, radius)
            //     .then((result) {
            //   log('found ${result.length} users');
            //   mapOptionsCubit.setOtherUsersLocations(result);
            //   alertsCubit.setAlerts(result);
            // });
            RedisDatabase()
                .getActiveUserLocations(userLocation.longitude,
                    userLocation.latitude, radius, _minutes)
                .then((result) => {
                      log('found ${result.length} users'),
                      mapOptionsCubit.setOtherUsersLocations(result),
                      alertsCubit.setAlerts(result)
                    });
          }
        }
      });
    } catch (e) {
      log('Error searching other users locations: $e');
    }
  }

  void _stopSearchingOtherUsersLocations() {
    if (_timerCheckOtherUsersLocation != null) {
      _timerCheckOtherUsersLocation?.cancel();
    }
    _timerCheckOtherUsersLocation = null;
  }

  void _listenToPositionStream() {
    _positionStreamSubscription =
        GeolocatorService.startBackgroundLocationService(foreground: true)
            .listen((Position position) {
      _actionsWithPosition(position);
    });
  }

  void _stopListeningToPositionStream() {
    log('cancel position stream');
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription?.cancel();
    }
    _positionStreamSubscription = null;
  }

  void _actionsWithPosition(Position position) async {
    final userDataCubit = context.read<UserDataCubit>();
    final mapOptionsCubit = context.read<MapOptionsCubit>();

    log('Position: ${position.latitude}, ${position.longitude}');

    setState(() {
      mapOptionsCubit.setUserLocation(UserLocationModel(
          userId: userDataCubit.state.userId,
          latitude: position.latitude,
          longitude: position.longitude));
    });
    RedisDatabase().storeUserLocation(UserLocationModel(
        userId: userDataCubit.state.userId,
        latitude: position.latitude,
        longitude: position.longitude,
        lastUpdate: DateTime.now().millisecondsSinceEpoch));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetAlert',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.black,
        actions: const <Widget>[
          // ElevatedButton.icon(
          //   onPressed: () {
          //     if (userDataCubit.state.walkingPets.isEmpty) {
          //       Get.snackbar('Error',
          //           'Debes seleccionar al menos una mascota para pasear',
          //           snackPosition: SnackPosition.BOTTOM,
          //           backgroundColor: Colors.red,
          //           colorText: Colors.white,
          //           margin: const EdgeInsets.all(8),
          //           duration: const Duration(seconds: 2));
          //     } else {
          //       context.read<WalkingCubit>().toggleWalking();
          //     }
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: context.watch<WalkingCubit>().state
          //         ? Colors.red
          //         : Colors.green,
          //     foregroundColor: Colors.white,
          //   ),
          //   icon: Icon(context.watch<WalkingCubit>().state
          //       ? Icons.directions_walk
          //       : Icons.directions_walk_sharp),
          //   label:
          //       Text(context.watch<WalkingCubit>().state ? 'Parar' : 'Iniciar'),
          // ),
          WalkingSwitch(),
          SizedBox(width: 8)
        ],
      ),
      body: userDataCubit.state.userId == ''
          ? const Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga si los datos están cargando
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: <Widget>[
                Container(
                  color: Colors.green,
                  child: FirstPage(pageController: _pageController),
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
                  child: AccountPage(userDataCubit: userDataCubit),
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
