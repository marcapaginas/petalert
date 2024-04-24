import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

final supabase = Supabase.instance.client;

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${supabase.auth.currentUser!.id}'),
            Text('Email: ${supabase.auth.currentUser!.email}'),
          ],
        ),
      ),
    );
  }
}
