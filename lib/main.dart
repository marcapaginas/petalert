import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/location_cubit.dart';
import 'package:pet_clean/blocs/markers_cubit.dart';
import 'package:pet_clean/blocs/username_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/pages/alert_detail_page.dart';
import 'package:pet_clean/pages/home_page.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/services/notification_service.dart';

void main() {
  NotificationService.initialize();
  GeolocatorService.checkServiceAndPermission();
  runApp(const BlocsProvider());
}

class BlocsProvider extends StatelessWidget {
  const BlocsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MarkersCubit()),
        BlocProvider(create: (context) => UsernameCubit()),
        BlocProvider(create: (context) => LocationCubit()),
        BlocProvider(create: (context) => AlertsCubit()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      initialRoute: '/', // La ruta que se carga inicialmente
      onGenerateRoute: (settings) {
        if (settings.name == '/alert_detail') {
          // Verificar si la ruta es '/alertDetail'
          // Obtener el objeto AlertModel de los argumentos pasados
          final args = settings.arguments as AlertModel;
          return MaterialPageRoute(
            builder: (context) {
              return AlertDetailPage(alert: args); // Pasar el objeto AlertModel
            },
          );
        }
        return null;
      },
    );
  }
}
