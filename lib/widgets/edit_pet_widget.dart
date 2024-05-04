import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/models/pet_model.dart';

class EditPet extends StatefulWidget {
  final int index;
  final UserDataCubit? userDataCubit;

  const EditPet({super.key, required this.index, required this.userDataCubit});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  PetBehavior? _selectedBehavior;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.userDataCubit!.state.pets[widget.index].name);
    _breedController = TextEditingController(
        text: widget.userDataCubit!.state.pets[widget.index].breed);
    _selectedBehavior = widget.userDataCubit!.state.pets[widget.index].behavior;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text('Editar mascota',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Comportamiento: '),
              const SizedBox(width: 16),
              DropdownButton<PetBehavior>(
                dropdownColor: Colors.white,
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
                hint: const Text('----'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  final pet = Pet(
                    name: _nameController.text,
                    breed: _breedController.text,
                    behavior: _selectedBehavior ?? PetBehavior.neutral,
                  );
                  try {
                    widget.userDataCubit!.updatePet(widget.index, pet);
                    Get.snackbar('Actualizado', '${pet.name} actualizado',
                        icon: const Icon(Icons.check),
                        colorText: Colors.white,
                        backgroundColor: Colors.green);
                    Navigator.of(context).pop();
                  } catch (e) {
                    log('Error actualizando mascota: $e');
                  }
                },
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
