import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/artista_model.dart';

class ArtistaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory mock list of artists for offline testing
  static final List<ArtistaModel> mockArtistas = [
    ArtistaModel(
      artistaId: 'artist_1',
      nombreArtistico: 'Adele',
      nombreReal: 'Adele Laurie Blue Adkins',
      paisOrigen: 'Reino Unido',
      biografia: 'Adele es una de las cantautoras más influyentes y exitosas del siglo XXI, conocida por su potente voz y baladas emocionales.',
      imagenUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
    ),
    ArtistaModel(
      artistaId: 'artist_2',
      nombreArtistico: 'Ed Sheeran',
      nombreReal: 'Edward Christopher Sheeran',
      paisOrigen: 'Reino Unido',
      biografia: 'Ed Sheeran es un cantante, compositor y guitarrista británico conocido por éxitos masivos como "Shape of You" y "Perfect".',
      imagenUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
    ),
    ArtistaModel(
      artistaId: 'artist_3',
      nombreArtistico: 'Taylor Swift',
      nombreReal: 'Taylor Alison Swift',
      paisOrigen: 'Estados Unidos',
      biografia: 'Taylor Swift es una cantante y compositora galardonada con múltiples premios Grammy, famosa por sus composiciones narrativas.',
      imagenUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    ),
  ];

  Future<List<ArtistaModel>> getArtistas() async {
    if (!FirebaseService.isFirebaseAvailable) {
      debugPrint("Retrieving mock artists list (Offline).");
      return List.from(mockArtistas);
    }

    try {
      final snapshot = await _firestore.collection('artistas').get();
      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore 'artistas' is empty. Falling back to local mock data.");
        return List.from(mockArtistas);
      }
      return snapshot.docs.map((doc) => ArtistaModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching artists from Firebase: $e. Falling back to local data.");
      return List.from(mockArtistas);
    }
  }

  Stream<List<ArtistaModel>> streamArtistas() {
    if (!FirebaseService.isFirebaseAvailable) {
      return Stream.value(List.from(mockArtistas));
    }
    return _firestore.collection('artistas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ArtistaModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> agregarArtista(ArtistaModel artista) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final id = 'artist_${DateTime.now().millisecondsSinceEpoch}';
      final newArtista = ArtistaModel(
        artistaId: id,
        nombreArtistico: artista.nombreArtistico,
        nombreReal: artista.nombreReal,
        paisOrigen: artista.paisOrigen,
        biografia: artista.biografia,
        imagenUrl: artista.imagenUrl.isEmpty
            ? 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300'
            : artista.imagenUrl,
      );
      mockArtistas.add(newArtista);
      return;
    }

    try {
      await _firestore.collection('artistas').add(artista.toMap());
    } catch (e) {
      throw Exception("Error al agregar artista: $e");
    }
  }

  Future<void> editarArtista(ArtistaModel artista) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final index = mockArtistas.indexWhere((a) => a.artistaId == artista.artistaId);
      if (index != -1) {
        mockArtistas[index] = artista;
      }
      return;
    }

    try {
      await _firestore.collection('artistas').doc(artista.artistaId).update(artista.toMap());
    } catch (e) {
      throw Exception("Error al editar artista: $e");
    }
  }

  Future<void> eliminarArtista(String artistaId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      mockArtistas.removeWhere((a) => a.artistaId == artistaId);
      return;
    }

    try {
      await _firestore.collection('artistas').doc(artistaId).delete();
    } catch (e) {
      throw Exception("Error al eliminar artista: $e");
    }
  }
}
