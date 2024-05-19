import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/widgets/pet_detail_widget.dart';

class MarkerDetailWidget extends StatefulWidget {
  final UserData userData;

  const MarkerDetailWidget({super.key, required this.userData});

  @override
  State<MarkerDetailWidget> createState() => _MarkerDetailWidgetState();
}

class _MarkerDetailWidgetState extends State<MarkerDetailWidget> {
  List<Widget> bottomSheetContent = [];

  @override
  Widget build(BuildContext context) {
    log('userData: ${widget.userData}');
    final pets =
        widget.userData.pets.where((pet) => pet.isBeingWalked).toList();

    return Container(
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
          SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text('${widget.userData.nombre} está paseando a: ',
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
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bottomSheetContent.clear();
                                        bottomSheetContent.add(
                                          PetDetailWidget(pet: pet),
                                        );
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: const AssetImage(
                                              'assets/pet.jpeg'),
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
                                ),
                              const SizedBox(width: 20),
                            ],
                          )
                        : const Text('No hay mascotas paseando'),
                    bottomSheetContent.isNotEmpty
                        ? Column(
                            children: bottomSheetContent,
                          )
                        : const SizedBox(),
                  ],
                )),
          ),
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
