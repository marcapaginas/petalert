import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
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

  static Future<String> uploadAvatar(File file, String name) async {
    try {
      // check if file exists to delete it
      try {
        await supabase.storage
            .from('fotos-perritos')
            .remove(['avatars/$name.jpg']);
      } catch (e) {
        // ignore
      }
      String filePath = 'avatars/$name.jpg';
      await supabase.storage
          .from('fotos-perritos')
          .upload(filePath, file, retryAttempts: 3);

      final signedURL = await supabase.storage
          .from('fotos-perritos')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);

      return signedURL;
    } catch (e) {
      log('Error uploading avatar: $e');
      return '';
    }
  }

  static Future<Image> getAvatar(String name) async {
    try {
      final response = await supabase.storage
          .from('fotos-perritos')
          .download('avatars/$name.jpg');

      return Image.memory(response);
    } catch (e) {
      log('Error getting avatar: $e');
      return Image.asset('assets/pet.jpeg');
    }
  }

  static Future<ImageProvider> getPetAvatar(String userId, String petId) async {
    try {
      final response = await supabase.storage
          .from('fotos-perritos')
          .download('avatars/$userId-$petId.jpg');

      return MemoryImage(response);
    } catch (e) {
      log('Error getting avatar - avatars/$userId-$petId.jpg - : $e');
      return const AssetImage('assets/pet.jpeg');
    }
  }

  static Future<void> deleteAvatar(String name) async {
    try {
      await supabase.storage
          .from('fotos-perritos')
          .remove(['avatars/$name.jpg']);
    } catch (e) {
      log('Error deleting avatar: $e');
    }
  }
}
