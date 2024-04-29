import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabase {
  static final SupabaseDatabase instance = SupabaseDatabase._();

  SupabaseDatabase._();

  static final supabase = Supabase.instance.client;

  // initalize

  static Future<void> initialize() async {
    await dotenv.load();
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
  }

  static Future<void> connect(
      {required String email, required String password}) async {
    try {
      await dotenv.load();
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log('Error connecting to Supabase: $e');
    }
  }
}
