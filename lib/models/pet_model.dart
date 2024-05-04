enum PetBehavior { bueno, neutral, malo }

class Pet {
  final String name;
  final String breed;
  final PetBehavior behavior;

  Pet({
    required this.name,
    required this.breed,
    required this.behavior,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'behavior': behavior.index,
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'],
      breed: map['breed'],
      behavior: PetBehavior.values[map['behavior']],
    );
  }
}
