class ArtistaModel {
  final String artistaId;
  final String nombreArtistico;
  final String nombreReal;
  final String paisOrigen;
  final String biografia;
  final String imagenUrl;

  ArtistaModel({
    required this.artistaId,
    required this.nombreArtistico,
    required this.nombreReal,
    required this.paisOrigen,
    required this.biografia,
    required this.imagenUrl,
  });

  factory ArtistaModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ArtistaModel(
      artistaId: documentId,
      nombreArtistico: data['nombreArtistico'] ?? '',
      nombreReal: data['nombreReal'] ?? '',
      paisOrigen: data['paisOrigen'] ?? '',
      biografia: data['biografia'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreArtistico': nombreArtistico,
      'nombreReal': nombreReal,
      'paisOrigen': paisOrigen,
      'biografia': biografia,
      'imagenUrl': imagenUrl,
    };
  }
}
