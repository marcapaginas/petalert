enum PetBehavior { bueno, neutral, malo }

class Pet {
  final String id;
  final String name;
  final String breed;
  final PetBehavior behavior;
  final bool isBeingWalked;
  final bool hasAvatar;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.behavior,
    this.isBeingWalked = false,
    this.hasAvatar = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'behavior': behavior.index,
      'isBeingWalked': isBeingWalked ? 'true' : 'false',
      'hasAvatar': hasAvatar ? 'true' : 'false',
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      behavior: PetBehavior.values[map['behavior']],
      isBeingWalked: map['isBeingWalked'] == 'true',
      hasAvatar: map['hasAvatar'] == 'true',
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    PetBehavior? behavior,
    bool? isBeingWalked,
    bool? hasAvatar,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      behavior: behavior ?? this.behavior,
      isBeingWalked: isBeingWalked ?? this.isBeingWalked,
      hasAvatar: hasAvatar ?? this.hasAvatar,
    );
  }
}
