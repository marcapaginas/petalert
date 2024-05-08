import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/widgets/lista_mascotas.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

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
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
                child: const Text('Ver perfil',
                    style: TextStyle(color: Colors.white))),
            ListaMascotas(userDataCubit: userDataCubit)
          ],
        ),
      ),
    );
  }
}
