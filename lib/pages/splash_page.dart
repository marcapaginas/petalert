import 'package:flutter/material.dart';
import 'package:pet_clean/database/supabase_database.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = SupabaseDatabase.supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/homepage');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/petalert-logo.png', width: 200),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text('Cargando...', style: TextStyle(color: Colors.white)),
          ],
        )),
      ),
    );
  }
}
