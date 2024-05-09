enum PetBehavior { bueno, neutral, malo }

class Pet {
  final String id;
  final String name;
  final String breed;
  final PetBehavior behavior;
  final bool isBeingWalked;
  final String avatarURL;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.behavior,
    this.isBeingWalked = false,
    this.avatarURL = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'behavior': behavior.index,
      'isBeingWalked': isBeingWalked ? 'true' : 'false',
      'avatarURL': avatarURL,
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      behavior: PetBehavior.values[map['behavior']],
      isBeingWalked: map['isBeingWalked'] == true,
      avatarURL: map['avatarURL'],
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    PetBehavior? behavior,
    bool? isBeingWalked,
    String? avatarURL,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      behavior: behavior ?? this.behavior,
      isBeingWalked: isBeingWalked ?? this.isBeingWalked,
      avatarURL: avatarURL ?? this.avatarURL,
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, breed: $breed, behavior: $behavior, isBeingWalked: $isBeingWalked, avatarURL: $avatarURL)';
  }
}
