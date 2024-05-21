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
import 'package:uuid/uuid.dart';

class PetManagerWidget extends StatefulWidget {
  final int? index;
  final String type;

  const PetManagerWidget({super.key, this.index, this.type = 'edit'});

  @override
  State<PetManagerWidget> createState() => _PetManagerState();
}

class _PetManagerState extends State<PetManagerWidget> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _notesController;
  PetAge? _selectedAge;
  PetBehavior? _selectedBehavior;
  PetSex? _selectedSex;
  final String _newPetID = const Uuid().v4();

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
    if (widget.index != null && widget.type == 'edit') {
      final userDataCubit = context.read<UserDataCubit>();
      _nameController = TextEditingController(
          text: userDataCubit.state.pets[widget.index!].name);
      _breedController = TextEditingController(
          text: userDataCubit.state.pets[widget.index!].breed);
      _selectedSex = userDataCubit.state.pets[widget.index!].petSex;
      _notesController = TextEditingController(
          text: userDataCubit.state.pets[widget.index!].notes);
      _selectedBehavior = userDataCubit.state.pets[widget.index!].behavior;
      _selectedAge = userDataCubit.state.pets[widget.index!].age;
    } else {
      _nameController = TextEditingController();
      _breedController = TextEditingController();
      _notesController = TextEditingController();
      _selectedBehavior = PetBehavior.bueno;
      _selectedSex = PetSex.macho;
      _selectedAge = PetAge.adulto;
    }
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
            Text(widget.type == 'edit' ? 'Editar mascota' : 'Añadir mascota',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 80,
              backgroundImage: const AssetImage('assets/pet.jpeg'),
              foregroundImage: widget.type == 'edit'
                  ? userDataCubit.state.pets[widget.index!].avatarURL.isNotEmpty
                      ? NetworkImage(
                          userDataCubit.state.pets[widget.index!].avatarURL)
                      : _image != null
                          ? FileImage(File(_image!.path))
                          : Image.asset('assets/pet.jpeg').image
                  : _image != null
                      ? FileImage(File(_image!.path))
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
                const Text('Género:'),
                const SizedBox(width: 16),
                DropdownButton<PetSex>(
                  value: _selectedSex,
                  items: PetSex.values.map((sex) {
                    return DropdownMenuItem<PetSex>(
                      value: sex,
                      child: Text(petSexValues[sex]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                  hint: const Text('Selecciona un sexo'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Comportamiento: '),
                const SizedBox(width: 8),
                DropdownButton<PetBehavior>(
                  borderRadius: BorderRadius.circular(8),
                  value: _selectedBehavior,
                  items: PetBehavior.values.map((behavior) {
                    return DropdownMenuItem<PetBehavior>(
                      value: behavior,
                      child: Text(petBehaviorValues[behavior]!,
                          style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBehavior = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Edad:'),
                const SizedBox(width: 16),
                DropdownButton<PetAge>(
                  borderRadius: BorderRadius.circular(8),
                  value: _selectedAge,
                  items: PetAge.values.map((age) {
                    return DropdownMenuItem<PetAge>(
                      value: age,
                      child: Text(petAgeValues[age]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // dropdown button with numbers from 0 to 30
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                helperText: '* Estas notas las verán otros usuarios',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.green),
                ),
                labelText: 'Notas',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  widget.type == 'edit'
                      ? _updatePet(userDataCubit, context)
                      : _addPet(userDataCubit, context);
                },
                child: Text(widget.type == 'edit' ? 'Actualizar' : 'Añadir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePet(UserDataCubit userDataCubit, BuildContext context) async {
    String imageURL = '';
    if (_image != null) {
      imageURL = await uploadImage();
    }

    final pet = Pet(
      id: userDataCubit.state.pets[widget.index!].id,
      name: _nameController.text,
      breed: _breedController.text,
      age: _selectedAge ?? PetAge.adulto,
      petSex: _selectedSex ?? PetSex.macho,
      behavior: _selectedBehavior!,
      isBeingWalked: userDataCubit.state.pets[widget.index!].isBeingWalked,
      avatarURL: imageURL.isNotEmpty
          ? imageURL
          : userDataCubit.state.pets[widget.index!].avatarURL,
      notes: _notesController.text,
    );
    try {
      if (_image != null) {
        uploadImage().then((value) => setPetAvatar(value));
      }
      userDataCubit.updatePet(widget.index!, pet);
      RedisDatabase().storeUserData(
        userDataCubit.state.copyWith(pets: [
          ...userDataCubit.state.pets
            ..removeAt(widget.index!)
            ..insert(widget.index!, pet)
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
  }

  void _addPet(UserDataCubit userDataCubit, BuildContext context) async {
    String imageURL = '';
    if (_image != null) {
      imageURL = await uploadImage();
    }

    final pet = Pet(
      id: _newPetID,
      name: _nameController.text,
      breed: _breedController.text,
      age: _selectedAge ?? PetAge.adulto,
      petSex: _selectedSex ?? PetSex.macho,
      behavior: _selectedBehavior!,
      isBeingWalked: false,
      avatarURL: imageURL,
      notes: _notesController.text,
    );
    try {
      userDataCubit.addPet(pet);
      Get.snackbar('Añadido', '${pet.name} añadido',
          icon: const Icon(Icons.check),
          colorText: Colors.white,
          backgroundColor: Colors.green);
      Navigator.of(context).pop();
    } catch (e) {
      log('Error añadiendo mascota: $e');
      Get.snackbar('Error', 'Error añadiendo mascota',
          icon: const Icon(Icons.error),
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  /// Upload image to Supabase storage
  /// and returns the URL String of the uploaded image
  Future<String> uploadImage() async {
    final userDataCubit = context.read<UserDataCubit>();
    final String petID = widget.type == 'edit'
        ? userDataCubit.state.pets[widget.index!].id
        : _newPetID;
    try {
      String imageURL = '';
      await SupabaseDatabase.uploadAvatar(
              File(_image!.path), '${supabase.auth.currentUser!.id}-$petID')
          .then((value) => imageURL = value);
      return imageURL;
    } catch (e) {
      log('Error uploading avatar: $e');
      return '';
    }
  }

  /// Set pet avatar URL in the user data cubit
  ///
  /// Uses the [avatarURL] to set the avatar URL in the user data cubit
  Future<void> setPetAvatar(String avatarURL) async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      userDataCubit.setPetAvatar(widget.index!, avatarURL);
    } catch (e) {
      log('Error marking pet with avatar: $e');
    }
  }

  /// Delete image from Supabase storage
  Future<void> deleteImage() async {
    if (_image != null) {
      _image = null;
      return;
    }

    final userDataCubit = context.read<UserDataCubit>();
    try {
      await SupabaseDatabase.deleteAvatar(
          '${supabase.auth.currentUser!.id}-${userDataCubit.state.pets[widget.index!].id}');
      _image = null;
    } catch (e) {
      log('Error deleting avatar: $e');
    }
  }

  /// Mark pet without avatar in the user data cubit
  Future<void> markPetWithoutAvatar() async {
    final userDataCubit = context.read<UserDataCubit>();
    try {
      userDataCubit.unsetPetAvatar(widget.index!);
    } catch (e) {
      log('Error marking pet without avatar: $e');
    }
  }

  /// Process image from camera or gallery
  /// and upload it to Supabase storage
  Future<void> processImage(String source) async {
    try {
      if (source == 'gallery') {
        await pickImageFromGallery();
        //await uploadImage().then((value) => setPetAvatar(value));
      } else {
        await pickImageFromCamera();
        //await uploadImage().then((value) => setPetAvatar(value));
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
