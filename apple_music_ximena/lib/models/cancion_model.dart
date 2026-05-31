class CancionModel {
  final String cancionId;
  final String titulo;
  final String artista;
  final String album;
  final int duracion; // in seconds
  final String audioUrl;
  final String imagenUrl;

  CancionModel({
    required this.cancionId,
    required this.titulo,
    required this.artista,
    required this.album,
    required this.duracion,
    required this.audioUrl,
    required this.imagenUrl,
  });

  factory CancionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CancionModel(
      cancionId: documentId,
      titulo: data['titulo'] ?? '',
      artista: data['artista'] ?? '',
      album: data['album'] ?? '',
      duracion: data['duracion'] ?? 0,
      audioUrl: data['audioUrl'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'artista': artista,
      'album': album,
      'duracion': duracion,
      'audioUrl': audioUrl,
      'imagenUrl': imagenUrl,
    };
  }

  String get formattedDuration {
    final minutes = duracion ~/ 60;
    final seconds = duracion % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
