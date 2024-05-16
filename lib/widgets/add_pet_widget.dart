import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:uuid/uuid.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key});

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  PetBehavior? _selectedBehavior;

  void _addNewPet(UserDataCubit userDataCubit) {
    final pet = Pet(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      breed: _breedController.text.trim(),
      behavior: _selectedBehavior ?? PetBehavior.neutral,
    );
    final updatedPets = [...userDataCubit.state.pets, pet];
    final updatedUserData = userDataCubit.state.copyWith(pets: updatedPets);
    RedisDatabase().storeUserData(updatedUserData);
    userDataCubit.setUserData(updatedUserData);
  }

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Añadir mascota',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
            ),
          ),
          TextFormField(
            controller: _breedController,
            decoration: const InputDecoration(
              labelText: 'Raza',
            ),
          ),
          // select behavior
          DropdownButton<PetBehavior>(
            value: _selectedBehavior,
            items: PetBehavior.values.map((behavior) {
              return DropdownMenuItem<PetBehavior>(
                value: behavior,
                child: Text(behavior.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBehavior = value;
              });
            },
            hint: const Text('Selecciona un comportamiento'),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              var uuid = const Uuid();
              final pet = Pet(
                id: uuid.v4(),
                name: _nameController.text.trim(),
                breed: _breedController.text.trim(),
                behavior: _selectedBehavior ?? PetBehavior.neutral,
              );
              try {
                _addNewPet(userDataCubit);
                Get.snackbar('¡Hola ${pet.name}!',
                    'Se ha añadido a ${pet.name} a tu lista de mascotas',
                    colorText: Colors.white,
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.check));
                Navigator.of(context).pop();
              } catch (e) {
                log('Error añadiendo mascota: $e');
              }
            },
            child: const Text('Añadir mascota'),
          ),
        ],
      ),
    );
  }
}
