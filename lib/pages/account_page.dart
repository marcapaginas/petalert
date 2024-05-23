import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/widgets/lista_mascotas.dart';
import 'package:pet_clean/widgets/pet_manager_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  final UserDataCubit userDataCubit;
  const AccountPage({super.key, required this.userDataCubit});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();

  var _loading = false;

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userDataCubit = widget.userDataCubit;
    final userName = _usernameController.text.trim();

    try {
      UserData user = userDataCubit.state.copyWith(nombre: userName);
      RedisDatabase().storeUserData(user);
      userDataCubit.setUserData(user);
      if (mounted) {
        Get.snackbar('EXITO', 'Perfil actualizado',
            backgroundColor: Colors.green, colorText: Colors.white);
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
    _usernameController.text = widget.userDataCubit.state.nombre;
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
        backgroundColor: Colors.green,
        actions: [
          const Text('Cerrar Sesión'),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre',
                        helperText:
                            'Ingresa tu nombre o apodo, será visible para otros usuarios'),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _loading ? null : _updateProfile,
                      child:
                          Text(_loading ? 'Guardando...' : 'Actualizar nombre'),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Tus mascotas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                userDataCubit.state.pets.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No tienes mascotas registradas'),
                              ElevatedButton(
                                onPressed: () {
                                  // Abre el formulario para añadir una nueva mascota
                                  Get.bottomSheet(
                                    isScrollControlled: true,
                                    const PetManagerWidget(type: 'add'),
                                  );
                                },
                                child: const Text('Añadir mascota'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const ListaMascotas(),
                const SizedBox(height: 25),
                // ElevatedButton(
                //   onPressed: () {
                //     // Abre el formulario para añadir una nueva mascota
                //     Get.bottomSheet(
                //       isScrollControlled: false,
                //       const AddPet(),
                //     );
                //   },
                //   child: const Text('Añadir mascota'),
                // ),
              ],
            ),
    );
  }
}
