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
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: 'Raza: ',
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: pet.breed.isNotEmpty ? pet.breed : 'No definida',
                    style: DefaultTextStyle.of(context).style),
              ])),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sexo: ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${petSexValues[pet.petSex]}',
                      style: DefaultTextStyle.of(context).style,
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Edad: ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${petAgeValues[pet.age]}',
                      style: DefaultTextStyle.of(context).style,
                    ),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Comportamiento: ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${petBehaviorValues[pet.behavior]}',
                      style: DefaultTextStyle.of(context).style,
                    ),
                  ],
                ),
              ),
              if (pet.notes.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Notas: ',
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: pet.notes,
                        style: DefaultTextStyle.of(context).style,
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ].animate().fadeIn(),
    );
  }
}
