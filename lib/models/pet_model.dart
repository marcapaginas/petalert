enum PetBehavior { bueno, neutral, malo }

class Pet {
  final String name;
  final String breed;
  final PetBehavior behavior;
  final bool isBeingWalked;

  Pet({
    required this.name,
    required this.breed,
    required this.behavior,
    this.isBeingWalked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'behavior': behavior.index,
      'isBeingWalked': isBeingWalked ? 'true' : 'false',
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'],
      breed: map['breed'],
      behavior: PetBehavior.values[map['behavior']],
      isBeingWalked: map['isBeingWalked'] == 'true',
    );
  }

  Pet copyWith({
    String? name,
    String? breed,
    PetBehavior? behavior,
    bool? isBeingWalked,
  }) {
    return Pet(
      name: name ?? this.name,
      breed: breed ?? this.breed,
      behavior: behavior ?? this.behavior,
      isBeingWalked: isBeingWalked ?? this.isBeingWalked,
    );
  }
}
