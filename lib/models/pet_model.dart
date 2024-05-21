import 'dart:convert' as convert;

enum PetBehavior { bueno, malMachos, malHembras, malNinos, malTodos }

const petBehaviorValues = {
  PetBehavior.bueno: 'Se lleva bien con todos',
  PetBehavior.malHembras: 'No se lleva bien con hembras',
  PetBehavior.malMachos: 'No se lleva bien con machos',
  PetBehavior.malNinos: 'No se lleva bien con niños',
  PetBehavior.malTodos: 'Mejor solo',
};

enum PetSex { macho, hembra }

const petSexValues = {
  PetSex.macho: 'Macho',
  PetSex.hembra: 'Hembra',
};

enum PetAge { cachorro, adolescente, adulto, anciano }

const petAgeValues = {
  PetAge.cachorro: 'Cachorro (0-6 meses)',
  PetAge.adolescente: 'Adolescente (6 meses - 2 años)',
  PetAge.adulto: 'Adulto (2-8 años)',
  PetAge.anciano: 'Anciano (8+ años)',
};

class Pet {
  final String id;
  final String name;
  final String breed;
  final PetAge age;
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
      age: PetAge.values[map['age']],
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
    PetAge? age,
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
        'age': age.index,
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
      age: PetAge.values[json['age']],
      petSex: PetSex.values[json['petSex']],
      behavior: PetBehavior.values[json['behavior']],
      isBeingWalked: json['isBeingWalked'],
      avatarURL: json['avatarURL'],
      notes: json['notes'],
    );
  }
}
