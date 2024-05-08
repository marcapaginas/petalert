import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/widgets/add_pet_widget.dart';
import 'package:pet_clean/widgets/lista_mascotas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();

  var _loading = true;

  UserData? userData;

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = SupabaseDatabase.supabase.auth.currentUser!.id;
      UserData userData = await MongoDatabase.getUserData(userId);
      if (mounted) {
        context.read<UserDataCubit>().setUserData(userData);
      }
      _usernameController.text = userData.nombre;
    } catch (error) {
      const SnackBar(
        content: Text('Error obteniendo perfil de usuario'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text.trim();

    try {
      await MongoDatabase.saveUserData(UserData(
        userId: Supabase.instance.client.auth.currentUser!.id,
        nombre: userName,
      ));
      if (mounted) {
        Get.snackbar('EXITO', 'Perfil actualizado');
      }
    } catch (error) {
      const SnackBar(
        content: Text('Error actualizando perfil de usuario'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseDatabase.supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
      );
    } catch (error) {
      const SnackBar(
        content: Text('Error cerrando sesión'),
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Perfil de usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _updateProfile,
                    child: Text(_loading ? 'Guardando...' : 'Actualizar'),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                      onPressed: _signOut, child: const Text('Cerrar sesión')),
                  const SizedBox(height: 25),
                  ListaMascotas(userDataCubit: userDataCubit),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      // Abre el formulario para añadir una nueva mascota
                      Get.bottomSheet(
                        AddPet(
                            userId:
                                Supabase.instance.client.auth.currentUser!.id,
                            userDataCubit: userDataCubit),
                      );
                    },
                    child: const Text('Añadir mascota'),
                  ),
                ],
              )),
    );
  }
}
