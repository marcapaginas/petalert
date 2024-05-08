import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/pages/home_page.dart';

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

  XFile? _image;

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? captureImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (captureImage != null) {
      setState(() {
        _image = captureImage;
      });
    }
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

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
    return SingleChildScrollView(
      child: Container(
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
                  borderRadius: BorderRadius.circular(8),
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
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final pet = Pet(
                      id: widget.userDataCubit!.state.pets[widget.index].id,
                      name: _nameController.text,
                      breed: _breedController.text,
                      behavior: _selectedBehavior ?? PetBehavior.neutral,
                    );
                    try {
                      MongoDatabase.updatePet(
                          widget.userDataCubit!.state.userId,
                          pet,
                          widget.index);
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
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 100,
              backgroundImage: const AssetImage('assets/pet.jpeg'),
              foregroundImage:
                  _image?.path != null ? FileImage(File(_image!.path)) : null,
            ),

            // image with a transparency from left to right
            Stack(
              children: [
                _image != null
                    ? Image.file(File(_image!.path),
                        width: 200, height: 200, fit: BoxFit.cover)
                    : Image.asset('assets/pet.jpeg',
                        width: 200, height: 200, fit: BoxFit.cover),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(1),
                      ],
                      transform: const GradientRotation(3.14 / 2),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              // Creating a button for picking an image
              onPressed: () {
                pickImageFromCamera();
              }, // Call the function to pick an image
              child: const Text('Pick Image From Camera'),
            ),
            ElevatedButton(
              // Creating a button for picking an image
              onPressed: () {
                pickImageFromGallery();
              }, // Call the function to pick an image
              child: const Text('Pick Image From Gallery'),
            ),
            ElevatedButton(
              // Creating a button for picking an image
              onPressed: () {
                removeImage();
              }, // Call the function to pick an image
              child: const Text('Remove Image'),
            ),
            ElevatedButton(
                onPressed: () {
                  try {
                    SupabaseDatabase.uploadAvatar(File(_image!.path),
                        '${supabase.auth.currentUser!.id}-${widget.userDataCubit!.state.pets[widget.index].id}');
                  } catch (e) {
                    log('Error uploading avatar: $e');
                  }
                },
                child: const Text('Subir foto'))
          ],
        ),
      ),
    );
  }
}
