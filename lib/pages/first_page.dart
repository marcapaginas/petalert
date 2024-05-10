import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/widgets/lista_mascotas.dart';
import 'package:pet_clean/widgets/lista_mascotas_circulos.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatelessWidget {
  final PageController pageController;

  FirstPage({super.key, required this.pageController});

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/perrito_marron_andando.json',
                width: 200, height: 200),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: Text(
                  '¡Bienvenido ${userDataCubit.state.nombre}! \n ¿Con quien vas a pasear hoy?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                'TUS MASCOTAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 5,
                ),
              ),
            ),
            userDataCubit.state.pets.isEmpty
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : ListaMascotasCirculos(userDataCubit: userDataCubit),
            ElevatedButton(
              onPressed: () {
                pageController.jumpToPage(1);
              },
              child: const Text('Ir a pasear'),
            )
          ],
        ),
      ),
    );
  }
}
