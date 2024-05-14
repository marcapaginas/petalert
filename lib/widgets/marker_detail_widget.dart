import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pet_clean/models/user_data_model.dart';

class MarkerDetailWidget extends StatelessWidget {
  final UserData userData;

  const MarkerDetailWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    log('userData: $userData');
    final pets = userData.pets.where((pet) => pet.isBeingWalked).toList();

    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text('${userData.nombre} está paseando a: ',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  pets.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var pet in pets)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          const AssetImage('assets/pet.jpeg'),
                                      foregroundImage: pet.avatarURL != ''
                                          ? NetworkImage(pet.avatarURL)
                                          : null,
                                      radius: 40,
                                    ),
                                    Text(
                                      pet.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 20),
                          ],
                        )
                      : const Text('No hay mascotas paseando'),
                ],
              )),
          Positioned(
            top: -80,
            left: 10,
            child: Image.asset(
              'assets/petalert-logo.png',
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
