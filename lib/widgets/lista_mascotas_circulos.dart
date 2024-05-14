import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/widgets/add_pet_widget.dart';

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
    return Expanded(
      child: LayoutBuilder(
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
                            widget.userDataCubit.switchPetBeingWalked(index);
                            RedisDatabase()
                                .storeUserData(widget.userDataCubit.state);

                            Get.rawSnackbar(
                              snackPosition: SnackPosition.TOP,
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              title: 'Actualizado',
                              message: widget.userDataCubit.state.pets[index]
                                      .isBeingWalked
                                  ? '¡${mascota.name} se viene al paseo!'
                                  : '${mascota.name} se queda en casa',
                              duration: const Duration(seconds: 2),
                            );
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
                                ),
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
                  // Si la mascota no existe, muestra un círculo con un icono de "+"
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        // Abre el BottomSlider con el widget de añadir mascota
                        Get.bottomSheet(
                          AddPet(
                              userDataCubit: widget.userDataCubit,
                              userId: widget.userDataCubit.state.userId),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Color.fromARGB(94, 238, 238, 238),
                        child: Icon(Icons.add),
                      ),
                    ),
                  );
                }
              }),
            ),
          );
        },
      ),
    );
  }
}
// class _ListaMascotasCirculosState extends State<ListaMascotasCirculos> {
//   @override
//   Widget build(BuildContext context) {
//     final userDataCubit = context.watch<UserDataCubit>();

//     return Expanded(
//       child: Wrap(
//         spacing: 2.0, // Espacio horizontal entre los elementos
//         runSpacing: 2.0, // Espacio vertical entre los elementos
//         children: List.generate(userDataCubit.state.pets.length, (index) {
//           final pet = userDataCubit.state.pets[index];
//           return FractionallySizedBox(
//             widthFactor:
//                 1 / 3, // Esto hace que el ancho sea 1/3 del ancho total
//             child: Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 child: Column(
//                   children: [
//                     InkWell(
//                       customBorder: const CircleBorder(),
//                       onTap: () {
//                         userDataCubit.switchPetBeingWalked(index);
//                         RedisDatabase().storeUserData(userDataCubit.state);
//                         Get.rawSnackbar(
//                           snackPosition: SnackPosition.TOP,
//                           animationDuration: const Duration(milliseconds: 500),
//                           title: 'Actualizado',
//                           message: userDataCubit.state.pets[index].isBeingWalked
//                               ? '¡${pet.name} se viene al paseo!'
//                               : '${pet.name} se queda en casa',
//                           duration: const Duration(seconds: 2),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 5,
//                             color: userDataCubit.state.pets[index].isBeingWalked
//                                 ? const Color.fromARGB(255, 101, 252, 7)
//                                 : Colors.white,
//                           ),
//                           color: Colors.green,
//                           shape: BoxShape.circle,
//                         ),
//                         child: CircleAvatar(
//                           radius: 45,
//                           backgroundImage: const AssetImage('assets/pet.jpeg'),
//                           foregroundImage:
//                               userDataCubit.state.pets[index].avatarURL != ''
//                                   ? NetworkImage(
//                                       userDataCubit.state.pets[index].avatarURL)
//                                   : Image.asset('assets/pet.jpeg').image,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       pet.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 )),
//           );
//         }),
//       ),
//     );
//   }
// }
