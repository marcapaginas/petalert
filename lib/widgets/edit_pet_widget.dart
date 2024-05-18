import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/database/supabase_database.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/pages/home_page.dart';

class EditPet extends StatefulWidget {
  final int index;

  const EditPet({super.key, required this.index});

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
      maxHeight: 512,
      maxWidth: 512,
    );

    if (mounted && pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      log('Image path: ${_image!.path}');
    }
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();

    final XFile? captureImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 512,
        maxWidth: 512);

    if (mounted && captureImage != null) {
      setState(() {
        _image = captureImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final userDataCubit = context.read<UserDataCubit>();
    _nameController = TextEditingController(
        text: userDataCubit.state.pets[widget.index].name);
    _breedController = TextEditingController(
        text: userDataCubit.state.pets[widget.index].breed);
    _selectedBehavior = userDataCubit.state.pets[widget.index].behavior;
  }

  @override
  Widget build(BuildContext context) {
    final userDataCubit = context.watch<UserDataCubit>();

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
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 80,
              backgroundImage: const AssetImage('assets/pet.jpeg'),
              foregroundImage:
                  userDataCubit.state.pets[widget.index].avatarURL.isNotEmpty
                      ? NetworkImage(
                          userDataCubit.state.pets[widget.index].avatarURL)
                      : Image.asset('assets/pet.jpeg').image,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Colors.green, // Cambia esto al color que prefieras
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      processImage('camera');
                    },
                    child: const Icon(
                      Icons.camera_alt, // Cambia esto al ícono que prefieras
                      color: Colors.white, // Cambia esto al color que prefieras
                    ),
                  ),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      processImage('gallery');
                    },
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      removeImage();
                      deleteImage();
                      markPetWithoutAvatar();
                    },
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final pet = Pet(
                      id: userDataCubit.state.pets[widget.index].id,
                      name: _nameController.text,
                      breed: _breedController.text,
                      behavior: _selectedBehavior!,
                      isBeingWalked:
                          userDataCubit.state.pets[widget.index].isBeingWalked,
                      avatarURL:
                          userDataCubit.state.pets[widget.index].avatarURL,
                    );
                    try {
                      userDataCubit.updatePet(widget.index, pet);
                      RedisDatabase().storeUserData(
                        userDataCubit.state.copyWith(pets: [
                          ...userDataCubit.state.pets
                            ..removeAt(widget.index)
                            ..insert(widget.index, pet)
                        ]),
                      );
                      Get.snackbar('Actualizado', '${pet.name} actualizado',
                          icon: const Icon(Icons.check),
                          colorText: Colors.white,
                          backgroundColor: Colors.green);
                      Navigator.of(context).pop();
                    } catch (e) {
                      log('Error actualizando mascota: $e');
                      Get.snackbar('Error', 'Error actualizando mascota',
                          icon: const Icon(Icons.error),
                          colorText: Colors.white,
                          backgroundColor: Colors.red);
                    }
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImage() async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      String imageURL = '';
      await SupabaseDatabase.uploadAvatar(File(_image!.path),
              '${supabase.auth.currentUser!.id}-${userDataCubit.state.pets[widget.index].id}')
          .then((value) => imageURL = value);
      return imageURL;
    } catch (e) {
      log('Error uploading avatar: $e');
      return '';
    }
  }

  Future<void> setPetAvatar(String avatarURL) async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      userDataCubit.setPetAvatar(widget.index, avatarURL);
    } catch (e) {
      log('Error marking pet with avatar: $e');
    }
  }

  Future<void> deleteImage() async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      SupabaseDatabase.deleteAvatar(
          '${supabase.auth.currentUser!.id}-${userDataCubit.state.pets[widget.index].id}');
    } catch (e) {
      log('Error deleting avatar: $e');
    }
  }

  Future<void> markPetWithoutAvatar() async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      userDataCubit.unsetPetAvatar(widget.index);
    } catch (e) {
      log('Error marking pet without avatar: $e');
    }
  }

  Future<void> processImage(String source) async {
    try {
      if (source == 'gallery') {
        await pickImageFromGallery();
        await uploadImage().then((value) => setPetAvatar(value));
      } else {
        await pickImageFromCamera();
        await uploadImage().then((value) => setPetAvatar(value));
      }
    } catch (e) {
      log('Error procesando imagen: $e');
      Get.snackbar('Error', 'Error procesando imagen',
          icon: const Icon(Icons.error),
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  Future<void> removeImage() async {
    try {
      await deleteImage();
      await markPetWithoutAvatar();
      setState(() {
        _image = null;
      });
    } catch (e) {
      log('Error eliminando imagen: $e');
      Get.snackbar('Error', 'Error eliminando imagen',
          icon: const Icon(Icons.error),
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }
}
