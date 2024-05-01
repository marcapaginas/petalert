class UserData {
  final int id;
  final String userId;
  final String nombre;
  final String apellidos;

  UserData(
      {required this.id,
      required this.userId,
      required this.nombre,
      required this.apellidos});

  static get empty {
    return UserData(id: 0, userId: '', nombre: '', apellidos: '');
  }

  UserData copyWith({
    int? id,
    String? userId,
    String? nombre,
    String? apellidos,
  }) {
    return UserData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
    );
  }

  @override
  String toString() {
    return 'UserData{id: $id, userId: $userId, nombre: $nombre, apellidos: $apellidos}';
  }
}
