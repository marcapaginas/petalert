import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/widgets/edit_pet_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final userDataCubit = context.watch<UserDataCubit>();

    return Expanded(
      child: Wrap(
        spacing: 2.0, // Espacio horizontal entre los elementos
        runSpacing: 2.0, // Espacio vertical entre los elementos
        children: List.generate(userDataCubit.state.pets.length, (index) {
          final pet = userDataCubit.state.pets[index];
          return FractionallySizedBox(
            widthFactor:
                1 / 3, // Esto hace que el ancho sea 1/3 del ancho total
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    MongoDatabase.switchPetBeingWalked(
                      Supabase.instance.client.auth.currentUser!.id,
                      index,
                    );
                    userDataCubit.switchPetBeingWalked(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 5,
                        color: userDataCubit.state.pets[index].isBeingWalked
                            ? Color.fromARGB(255, 101, 252, 7)
                            : Colors.white,
                      ),
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: const AssetImage('assets/pet.jpeg'),
                      foregroundImage:
                          userDataCubit.state.pets[index].avatarURL != ''
                              ? NetworkImage(
                                  userDataCubit.state.pets[index].avatarURL)
                              : Image.asset('assets/pet.jpeg').image,
                    ),
                  ),
                )),
          );
        }),
      ),
    );

    // return Expanded(
    //   child: GridView.count(
    //     crossAxisCount: 3,
    //     children: List.generate(userDataCubit.state.pets.length, (index) {
    //       final pet = userDataCubit.state.pets[index];
    //       return Padding(
    //         padding: const EdgeInsets.all(2.0),
    //         child: GestureDetector(
    //           onTap: () {
    //             if (widget.editar) {
    //               // editar
    //             }
    //           },
    //           child: Container(
    //             decoration: BoxDecoration(
    //               border: Border.all(color: Colors.white),
    //               color: Colors.green,
    //               borderRadius: BorderRadius.circular(100),
    //             ),
    //             child: CircleAvatar(
    //               radius: 55,
    //               backgroundImage: const AssetImage('assets/pet.jpeg'),
    //               foregroundImage: userDataCubit.state.pets[index].avatarURL !=
    //                       ''
    //                   ? NetworkImage(userDataCubit.state.pets[index].avatarURL)
    //                   : Image.asset('assets/pet.jpeg').image,
    //             ),
    //           ),
    //         ),
    //       );
    //     }),
    //   ),
    // );
  }
}
