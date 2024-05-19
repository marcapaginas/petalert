import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/pages/forgot_password_page.dart';
import 'package:pet_clean/pages/home_page.dart';
import 'package:pet_clean/pages/login_page.dart';
import 'package:pet_clean/pages/no_connection_page.dart';
import 'package:pet_clean/pages/register_page.dart';
import 'package:pet_clean/pages/splash_page.dart';
import 'package:pet_clean/services/connection_service.dart';
import 'package:pet_clean/services/geolocator_service.dart';
import 'package:pet_clean/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  SupabaseDatabase.initialize();
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
        BlocProvider(create: (context) => UserDataCubit()),
        BlocProvider(
            create: (context) => AlertsCubit(context.read<UserDataCubit>())),
        BlocProvider(create: (context) => MapOptionsCubit()),
        BlocProvider(create: (context) => WalkingCubit()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ConnectionService().initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: 'PetAlert',
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/register': (_) => RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/forgot-password': (_) => const ForgotPassword(),
        '/homepage': (_) => const HomePage(),
        '/no-connection': (_) => const NoConnectionPage(),
      },
    );
  }
}
