import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/user_location_model.dart';
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
            Lottie.asset('assets/andando.json',
                width: 200, height: 180, fit: BoxFit.cover),
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
            ),
            const Text('¿Con quien vas a pasear hoy?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                )),
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
            // Text('${userDataCubit.state}',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 10,
            //     )),
            userDataCubit.state.isBlank!
                ? const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)))
                : userDataCubit.state.pets.isNotEmpty
                    ? ListaMascotasCirculos(userDataCubit: userDataCubit)
                    : const Text('No hay mascotas'),
            ElevatedButton(
              onPressed: () {
                pageController.jumpToPage(1);
              },
              child: const Text('Ir a pasear'),
            ),
            ElevatedButton(
                onPressed: () {
                  // RedisDatabase().storeUserData(
                  //     Supabase.instance.client.auth.currentUser!.id,
                  //     userDataCubit.state);
                  // RedisDatabase().getUserData(
                  //     Supabase.instance.client.auth.currentUser!.id);
                  // RedisDatabase().storeUserLocation(UserLocationModel(
                  //     userId: '4444',
                  //     latitude: 37.97245364300349735,
                  //     longitude: -1.20698601007461548));

                  // 37.972441, -1.207259  - 37.972413, -1.208022

                  // RedisDatabase().getUserLocationsByDistance(
                  //     -1.206450, 37.971963, 9999999);

                  //RedisDatabase().getUserLocations();
                },
                child: const Text('Prueba'))
          ],
        ),
      ),
    );
  }
}
