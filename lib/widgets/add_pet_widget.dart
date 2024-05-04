import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/pet_model.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key, required this.userId, required this.userDataCubit});

  final String userId;
  final UserDataCubit userDataCubit;

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  PetBehavior? _selectedBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Añadir mascota'),
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
              final pet = Pet(
                name: _nameController.text,
                breed: _breedController.text,
                behavior: _selectedBehavior ?? PetBehavior.neutral,
              );
              try {
                widget.userDataCubit.addPet(pet);
                MongoDatabase.addPet(widget.userId, pet);
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
