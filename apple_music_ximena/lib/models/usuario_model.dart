class UsuarioModel {
  final String uid;
  final String nombre;
  final String email;
  final String foto;
  final DateTime fechaRegistro;
  final String rol; // 'admin' or 'user'

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.email,
    this.foto = '',
    required this.fechaRegistro,
    this.rol = 'user',
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UsuarioModel(
      uid: documentId,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      foto: data['foto'] ?? '',
      fechaRegistro: data['fechaRegistro'] != null
          ? DateTime.parse(data['fechaRegistro'])
          : DateTime.now(),
      rol: data['rol'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'foto': foto,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'rol': rol,
    };
  }
}
