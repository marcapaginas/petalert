import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  //late final TextEditingController _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //final userDataCubit = context.watch<UserDataCubit>();

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${supabase.auth.currentUser!.id}'),
            Text('Email: ${supabase.auth.currentUser!.email}'),
            // userDataCubit.state.nombre.isEmpty
            //     ? const CircularProgressIndicator()
            //     : Text(
            //         '¡Hola ${userDataCubit.state.nombre}!',
            //         style: const TextStyle(
            //             fontSize: 24, fontWeight: FontWeight.bold),
            //       ),
            // const SizedBox(height: 20),
            // TextFormField(
            //   controller: _nombreController,
            //   decoration: const InputDecoration(
            //       labelText: 'Nombre',
            //       hintText: 'Escribe tu nombre',
            //       fillColor: Colors.white,
            //       filled: true),
            // ),
            // const SizedBox(height: 18),
            // ElevatedButton(
            //     onPressed: () {
            //       MongoDatabase.saveUserData(UserData(
            //         userId: supabase.auth.currentUser!.id,
            //         nombre: _nombreController.text,
            //       ));
            //       userDataCubit.setUserData(
            //         UserData(
            //           userId: supabase.auth.currentUser!.id,
            //           nombre: _nombreController.text,
            //         ),
            //       );
            //     },
            //     child: const Text('Enviar Datos')),
            //Text(userDataCubit.state.toString()),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
                child: const Text('Ver perfil',
                    style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}

final supabase = Supabase.instance.client;
