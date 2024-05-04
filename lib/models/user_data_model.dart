class UserData {
  final int id;
  final String userId;
  final String nombre;

  UserData({
    required this.id,
    required this.userId,
    required this.nombre,
  });

  static get empty {
    return UserData(id: 0, userId: '', nombre: '');
  }

  UserData copyWith({
    int? id,
    String? userId,
    String? nombre,
  }) {
    return UserData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  String toString() {
    return 'UserData{id: $id, userId: $userId, nombre: $nombre}';
  }
}
