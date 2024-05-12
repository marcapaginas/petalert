import 'package:pet_clean/models/pet_model.dart';
import 'dart:convert' as convert;
import 'package:redis/redis.dart';

class UserData {
  final String userId;
  final String nombre;
  final List<Pet> pets;

  UserData({
    required this.userId,
    required this.nombre,
    this.pets = const [],
  });

  static get empty {
    return UserData(userId: '', nombre: '', pets: []);
  }

  String toJson() => convert.jsonEncode({
        'userId': userId,
        'nombre': nombre,
        'pets': pets.map((pet) => pet.toJson()).toList(),
      });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      nombre: json['nombre'],
      pets: List<Pet>.from(
          json['pets']?.map((pet) => Pet.fromJson(convert.jsonDecode(pet)))),
    );
  }

  UserData copyWith({
    String? userId,
    String? nombre,
    List<Pet>? pets,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      pets: pets ?? this.pets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nombre': nombre,
      'pets': pets.map((x) => x.toMap()).toList(),
    };
  }

  get walkingPets {
    return pets.where((pet) => pet.isBeingWalked).toList();
  }

  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      userId: map['userId'],
      nombre: map['nombre'],
      pets: List<Pet>.from(map['pets']?.map((x) => Pet.fromMap(x))),
    );
  }

  // Flatten the map into key-value pairs for HMSET
  List<String> toRedis() {
    final userDataMap = toMap();
    final List<String> userDataArgs =
        userDataMap.entries.fold<List<String>>([], (acc, entry) {
      acc.addAll([entry.key, entry.value.toString()]);
      return acc;
    });
    return userDataArgs;
  }

  // convert from redis to userData
  static UserData fromRedis(List<String> redisResponse) {
    final userDataMap = Map<String, dynamic>.fromEntries(
      List.generate(
        (redisResponse.length / 2).floor(),
        (index) => MapEntry(
          redisResponse[index * 2],
          redisResponse[index * 2 + 1],
        ),
      ),
    );

    return UserData.fromMap(userDataMap);
  }

  @override
  String toString() {
    return 'UserData(userId: $userId, nombre: $nombre, pets: $pets)';
  }
}
