import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabase {
  static final SupabaseDatabase instance = SupabaseDatabase._();

  SupabaseDatabase._();

  static final supabase = Supabase.instance.client;

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
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log('Error conectando a Supabase: $e');
    }
  }

  static Future<void> disconnect() async {
    await supabase.auth.signOut();
    // TODO: go to login page
  }

  static Future<void> signUp(
      {required String email, required String password}) async {
    try {
      await supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      log('Error signing up: $e');
    }
  }

  static void setUserData(
      Map<String, dynamic> datos, BuildContext context) async {
    String nombre = datos['nombre'];

    if (nombre.isEmpty) {
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    final data = {
      'user_id': user.id,
      'nombre': nombre,
    };

    await supabase.from('users').upsert(data, onConflict: 'user_id').onError(
        (error, stackTrace) => log('Error enviando datos de usuario: $error'));

    Get.snackbar('Correcto', 'Datos guardados correctamente',
        backgroundColor: Colors.white, icon: const Icon(Icons.check));
  }

  static Future<UserData> getUserData(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .limit(1)
          .single();

      final data = response.map((key, value) => MapEntry(key, value));

      final userData = UserData(
        userId: data['user_id'] as String,
        nombre: data['nombre'] as String,
      );

      return userData;
    } catch (e) {
      log('Error getting user data: $e');
    }
    return UserData.empty;
  }
}
