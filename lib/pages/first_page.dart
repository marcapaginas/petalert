import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

final supabase = Supabase.instance.client;

class _FirstPageState extends State<FirstPage> {
  final String _userId = supabase.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: $_userId'),
            Text('Email: ${supabase.auth.currentUser!.email}'),
            ElevatedButton(
                onPressed: () => _addMarker(),
                child: const Text('añadir marcador'))
          ],
        ),
      ),
    );
  }

  void _addMarker() async {
    await supabase.from('restaurants').insert([
      {
        'name': 'Supa Burger',
        'location': 'POINT(-73.946823 40.807416)',
      },
      {
        'name': 'Supa Pizza',
        'location': 'POINT(-73.94581 40.807475)',
      },
      {
        'name': 'Supa Taco',
        'location': 'POINT(-73.945826 40.80629)',
      },
    ]);
  }
}
