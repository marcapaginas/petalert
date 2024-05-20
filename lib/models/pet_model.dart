import 'dart:convert' as convert;

enum PetBehavior { bueno, neutral, malo }

enum PetSex { macho, hembra }

class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final PetSex petSex;
  final PetBehavior behavior;
  final bool isBeingWalked;
  final String avatarURL;
  final String notes;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.petSex,
    required this.behavior,
    this.isBeingWalked = false,
    this.avatarURL = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'petSex': petSex.index,
      'behavior': behavior.index,
      'isBeingWalked': isBeingWalked ? true : false,
      'avatarURL': avatarURL,
      'notes': notes,
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      age: map['age'],
      petSex: PetSex.values[map['petSex']],
      behavior: PetBehavior.values[map['behavior']],
      isBeingWalked: map['isBeingWalked'] == true,
      avatarURL: map['avatarURL'],
      notes: map['notes'],
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    int? age,
    PetSex? petSex,
    PetBehavior? behavior,
    bool? isBeingWalked,
    String? avatarURL,
    String? notes,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      petSex: petSex ?? this.petSex,
      behavior: behavior ?? this.behavior,
      isBeingWalked: isBeingWalked ?? this.isBeingWalked,
      avatarURL: avatarURL ?? this.avatarURL,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, breed: $breed, age: $age, sex: $petSex, behavior: $behavior, isBeingWalked: $isBeingWalked, avatarURL: $avatarURL, notes: $notes)';
  }

  String toJson() => convert.jsonEncode({
        'id': id,
        'name': name,
        'breed': breed,
        'age': age,
        'petSex': petSex.index,
        'behavior': behavior.index,
        'isBeingWalked': isBeingWalked,
        'avatarURL': avatarURL,
        'notes': notes,
      });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      petSex: PetSex.values[json['petSex']],
      behavior: PetBehavior.values[json['behavior']],
      isBeingWalked: json['isBeingWalked'],
      avatarURL: json['avatarURL'],
      notes: json['notes'],
    );
  }
}
