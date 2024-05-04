import 'package:pet_clean/models/pet_model.dart';

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

  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      userId: map['userId'],
      nombre: map['nombre'],
      pets: List<Pet>.from(map['pets']?.map((x) => Pet.fromMap(x))),
    );
  }

  @override
  String toString() {
    return 'UserData{userId: $userId, nombre: $nombre}';
  }
}
