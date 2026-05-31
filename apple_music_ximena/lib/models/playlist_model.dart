class PlaylistModel {
  final String playlistId;
  final String nombre;
  final String descripcion;
  final String usuarioId;
  final List<String> cancionesIds;

  PlaylistModel({
    required this.playlistId,
    required this.nombre,
    required this.descripcion,
    required this.usuarioId,
    required this.cancionesIds,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PlaylistModel(
      playlistId: documentId,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      cancionesIds: List<String>.from(data['cancionesIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'usuarioId': usuarioId,
      'cancionesIds': cancionesIds,
    };
  }
}
