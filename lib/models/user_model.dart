class UserModel {
  final String id;
  final String nombre;

  UserModel({
    required this.id,
    required this.nombre,
  });

  @override
  String toString() {
    return 'UserModel{id: $id, nombre: $nombre}';
  }
}
