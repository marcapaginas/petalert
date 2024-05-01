import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatelessWidget {
  FirstPage({super.key});

  late final TextEditingController _nombreController = TextEditingController();

  late final TextEditingController _apellidosController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${supabase.auth.currentUser!.id}'),
            Text('Email: ${supabase.auth.currentUser!.email}'),
            userDataCubit.state.nombre.isEmpty
                ? const CircularProgressIndicator()
                : Text(
                    '¡Hola ${userDataCubit.state.nombre}!',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _apellidosController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
                onPressed: () {
                  SupabaseDatabase.setUserData({
                    'nombre': _nombreController.text,
                    'apellidos': _apellidosController.text,
                  }, context);
                },
                child: const Text('Enviar Datos')),
            Text(userDataCubit.state.toString()),
          ],
        ),
      ),
    );
  }
}

final supabase = Supabase.instance.client;
