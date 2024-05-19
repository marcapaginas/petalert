import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pet_clean/models/pet_model.dart';

class PetDetailWidget extends StatelessWidget {
  final Pet pet;

  const PetDetailWidget({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Text(pet.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                'Raza: ${pet.breed}',
              ),
              Text('Comportamiento: ${pet.behavior.name}'),
            ],
          ),
        ),
      ].animate().fadeIn(),
    );
  }
}
