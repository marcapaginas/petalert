import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/pages/alerts.dart';
import 'package:pet_clean/pages/first_page.dart';
import 'package:pet_clean/pages/settings.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/widgets/mapa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

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
  void initState() {
    super.initState();
    GeolocatorService.startBackgroundLocationService();
    _listenToPositionStream();
  }

  void _listenToPositionStream() {
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // _pageController.animateToPage(index,
      //     duration: Duration(milliseconds: 300), curve: Curves.ease);
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetAlert'),
        //actions: const [CustomSwitch()],
        backgroundColor: Colors.green,
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
            color: Colors.blue,
            child: const FirstPage(),
          ),
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(20),
            child: const Mapa(),
          ),
          Container(
            color: Colors.green,
            child: const Alerts(),
          ),
          Container(
            color: Colors.red,
            child: const Center(
              child: Settings(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AlertsCubit, List<AlertModel>>(
        builder: (context, state) {
          return NavigationBar(
            backgroundColor: Colors.white24,
            onDestinationSelected: _onItemTapped,
            indicatorColor: Colors.greenAccent,
            selectedIndex: _selectedIndex,
            destinations: <NavigationDestination>[
              const NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Inicio',
              ),
              const NavigationDestination(
                icon: Icon(Icons.map),
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
          );
        },
      ),
    );
  }
}
