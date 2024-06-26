import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/widgets/pet_manager_widget.dart';

class ListaMascotasCirculos extends StatefulWidget {
  final UserDataCubit userDataCubit;
  final bool editar;

  const ListaMascotasCirculos(
      {super.key, required this.userDataCubit, this.editar = false});

  @override
  State<ListaMascotasCirculos> createState() => _ListaMascotasCirculosState();
}

class _ListaMascotasCirculosState extends State<ListaMascotasCirculos> {
  @override
  Widget build(BuildContext context) {
    var walkingCubit = context.watch<WalkingCubit>();

    return Expanded(child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: List.generate(4, (index) {
              if (index < widget.userDataCubit.state.pets.length) {
                Pet mascota = widget.userDataCubit.state.pets[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if (walkingCubit.state) {
                            Get.rawSnackbar(
                              snackPosition: SnackPosition.TOP,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              title: '¡Espera!',
                              message:
                                  'No puedes cambiar de mascota mientras estás paseando',
                              duration: const Duration(seconds: 1),
                            );
                          } else {
                            widget.userDataCubit.switchPetBeingWalked(index);
                            RedisDatabase()
                                .storeUserData(widget.userDataCubit.state);

                            Get.rawSnackbar(
                              snackPosition: SnackPosition.TOP,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              title: 'Actualizado',
                              message: widget.userDataCubit.state.pets[index]
                                      .isBeingWalked
                                  ? '¡${mascota.name} se viene al paseo!'
                                  : '${mascota.name} se queda en casa',
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  const Color.fromARGB(255, 115, 219, 118),
                              backgroundImage: mascota.avatarURL != ''
                                  ? null
                                  : const AssetImage('assets/pet.jpeg'),
                              foregroundImage: mascota.avatarURL != ''
                                  ? NetworkImage(mascota.avatarURL)
                                  : null,
                            ),
                            if (mascota.isBeingWalked)
                              Transform.translate(
                                offset: const Offset(8, -8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Color.fromARGB(255, 101, 252, 7),
                                  ),
                                ),
                              ).animate().fade(duration: 300.ms),
                          ],
                        ),
                      ),
                      Text(
                        mascota.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Get.bottomSheet(
                        isScrollControlled: true,
                        const PetManagerWidget(type: 'add'),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(94, 238, 238, 238),
                      child: Icon(Icons.add),
                    ),
                  ),
                );
              }
            }).animate(interval: 300.ms).fade(duration: 300.ms),
          ),
        );
      },
    ));
  }
}
