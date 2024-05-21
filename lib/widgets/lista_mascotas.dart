import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/widgets/pet_manager_widget.dart';

class ListaMascotas extends StatefulWidget {
  const ListaMascotas({super.key});

  @override
  State<ListaMascotas> createState() => _ListaMascotasState();
}

class _ListaMascotasState extends State<ListaMascotas> {
  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: userDataCubit.state.pets.length,
          itemBuilder: (context, index) {
            final pet = userDataCubit.state.pets[index];
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: const BoxDecoration(
                  border:
                      Border.fromBorderSide(BorderSide(color: Colors.white)),
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: const AssetImage('assets/pet.jpeg'),
                      foregroundImage:
                          userDataCubit.state.pets[index].avatarURL != ''
                              ? NetworkImage(
                                  userDataCubit.state.pets[index].avatarURL)
                              : Image.asset('assets/pet.jpeg').image,
                    ),
                    title: Text(pet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet.breed}',
                        style: const TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Get.bottomSheet(
                              isScrollControlled: true,
                              PetManagerWidget(
                                index: index,
                              ),
                            );
                          },
                          color: Colors.white,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            Get.dialog(AlertDialog(
                              title:
                                  Text('Quitar a ${pet.name} de tus mascotas'),
                              content: const Text(
                                  '¿Estás seguro de quitar esta mascota?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back(closeOverlays: true);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    try {
                                      Get.back(closeOverlays: true);
                                      userDataCubit.removePet(index);
                                      RedisDatabase()
                                          .storeUserData(userDataCubit.state);
                                      Get.snackbar('Exito',
                                          'Se ha quitado a ${pet.name} de tus mascotas',
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white);
                                      Get.back(closeOverlays: true);
                                    } catch (e) {
                                      Get.snackbar(
                                          'Error', 'Error quitando mascota',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white);
                                    }
                                  },
                                  child: const Text('Quitar'),
                                ),
                              ],
                            ));
                          },
                          color: Colors.white,
                        ),
                      ],
                    ),
                    tileColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            );
          },
        ).animate().fade().slide(
              begin: const Offset(0, 0.1),
              duration: const Duration(milliseconds: 300),
            ),
      ),
    );
  }
}
