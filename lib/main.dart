import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/pages/account_page.dart';
import 'package:pet_clean/pages/alert_detail_page.dart';
import 'package:pet_clean/pages/home_page.dart';
import 'package:pet_clean/pages/login_page.dart';
import 'package:pet_clean/pages/register_page.dart';
import 'package:pet_clean/pages/splash_page.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  SupabaseDatabase.initialize();
  NotificationService.initialize();
  GeolocatorService.checkServiceAndPermission();

  runApp(const GetMaterialApp(home: BlocsProvider()));
}

class BlocsProvider extends StatelessWidget {
  const BlocsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AlertsCubit()),
        BlocProvider(create: (context) => MapOptionsCubit()),
        BlocProvider(create: (context) => UserDataCubit()),
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
      title: 'PetAlert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/register': (_) => RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/account': (_) => const AccountPage(),
        '/homepage': (_) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/alert_detail') {
          final args = settings.arguments as AlertModel;
          return MaterialPageRoute(
            builder: (context) {
              return AlertDetailPage(alert: args);
            },
          );
        }
        return null;
      },
    );
  }
}
