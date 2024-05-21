import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/widgets/lista_mascotas_circulos.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatelessWidget {
  final PageController pageController;

  FirstPage({super.key, required this.pageController});

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();
    final int petWalkingCount =
        userDataCubit.state.pets.where((pet) => pet.isBeingWalked).length;

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Lottie.asset('assets/andando.json',
                  width: 200, height: 180, fit: BoxFit.cover),
            ).animate().fade(),
            Center(
              child: Text(
                '¡Hola ${userDataCubit.state.nombre}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fade(),
            const Text('¿Con quien vas a pasear hoy?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                )).animate().fade(),
            const Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: Text(
                'TUS MASCOTAS',
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 77, 22),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 5,
                ),
              ),
            ),
            userDataCubit.state.isBlank!
                ? const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)))
                : ListaMascotasCirculos(userDataCubit: userDataCubit),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: petWalkingCount > 0
                  ? null
                  : const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('Selecciona al menos una mascota para pasear',
                          style: TextStyle(color: Colors.white)),
                    ).animate().fade(),
            ),
          ],
        ),
      ),
    );
  }
}
