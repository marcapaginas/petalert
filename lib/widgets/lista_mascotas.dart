import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/widgets/edit_pet_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListaMascotas extends StatefulWidget {
  final UserDataCubit userDataCubit;

  const ListaMascotas({super.key, required this.userDataCubit});

  @override
  State<ListaMascotas> createState() => _ListaMascotasState();
}

class _ListaMascotasState extends State<ListaMascotas> {
  HashMap<String, ImageProvider> petAvatars = HashMap();

  @override
  void initState() {
    super.initState();
    _getPetAvatars(widget.userDataCubit);
  }

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Expanded(
      child: ListView.builder(
        itemCount: userDataCubit.state.pets.length,
        itemBuilder: (context, index) {
          final pet = userDataCubit.state.pets[index];
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: const AssetImage('assets/pet.jpeg'),
                    foregroundImage: petAvatars[pet.id],
                  ),
                  title: Text(pet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${pet.breed} - ${pet.behavior.name}',
                      style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Get.bottomSheet(
                            isScrollControlled: true,
                            EditPet(
                              index: index,
                              userDataCubit: userDataCubit,
                            ),
                          );
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          Get.dialog(AlertDialog(
                            title: Text('Quitar a ${pet.name} de tus mascotas'),
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
                                    MongoDatabase.deletePet(
                                        Supabase.instance.client.auth
                                            .currentUser!.id,
                                        index);
                                    userDataCubit.removePet(index);
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
      ),
    );
  }

  void _getPetAvatars(UserDataCubit userDataCubit) async {
    for (var pet in userDataCubit.state.pets) {
      await SupabaseDatabase.getPetAvatar(userDataCubit.state.userId, pet.id)
          .then((value) {
        petAvatars[pet.id] = value;
      });
    }
  }
}
