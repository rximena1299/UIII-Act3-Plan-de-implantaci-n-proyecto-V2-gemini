import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/cancion_model.dart';
import '../models/playlist_model.dart';

class MusicRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory mock list of songs for offline testing
  static final List<CancionModel> mockCanciones = [
    CancionModel(
      cancionId: 'song_1',
      titulo: 'Rolling in the Deep',
      artista: 'Adele',
      album: '21',
      duracion: 228, // 3:48
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=300',
    ),
    CancionModel(
      cancionId: 'song_2',
      titulo: 'Shape of You',
      artista: 'Ed Sheeran',
      album: '÷ (Divide)',
      duracion: 233, // 3:53
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300',
    ),
    CancionModel(
      cancionId: 'song_3',
      titulo: 'Blank Space',
      artista: 'Taylor Swift',
      album: '1989',
      duracion: 231, // 3:51
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300',
    ),
    CancionModel(
      cancionId: 'song_4',
      titulo: 'Someone Like You',
      artista: 'Adele',
      album: '21',
      duracion: 285, // 4:45
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300',
    ),
    CancionModel(
      cancionId: 'song_5',
      titulo: 'Perfect',
      artista: 'Ed Sheeran',
      album: '÷ (Divide)',
      duracion: 263, // 4:23
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
    ),
    CancionModel(
      cancionId: 'song_6',
      titulo: 'Hello',
      artista: 'Adele',
      album: '25',
      duracion: 295, // 4:55
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=300',
    ),
    CancionModel(
      cancionId: 'song_7',
      titulo: 'Photograph',
      artista: 'Ed Sheeran',
      album: 'x (Multiply)',
      duracion: 259, // 4:19
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1487180142328-0c4e37023af5?w=300',
    ),
    CancionModel(
      cancionId: 'song_8',
      titulo: 'Cruel Summer',
      artista: 'Taylor Swift',
      album: 'Lover',
      duracion: 178, // 2:58
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300',
    ),
    CancionModel(
      cancionId: 'song_9',
      titulo: 'Set Fire to the Rain',
      artista: 'Adele',
      album: '21',
      duracion: 242, // 4:02
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300',
    ),
    CancionModel(
      cancionId: 'song_10',
      titulo: 'Castle on the Hill',
      artista: 'Ed Sheeran',
      album: '÷ (Divide)',
      duracion: 261, // 4:21
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300',
    ),
    CancionModel(
      cancionId: 'song_11',
      titulo: 'Shake It Off',
      artista: 'Taylor Swift',
      album: '1989',
      duracion: 219, // 3:39
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      imagenUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=300',
    ),
  ];

  // In-memory mock list of playlists for offline testing
  static final List<PlaylistModel> mockPlaylists = [
    PlaylistModel(
      playlistId: 'playlist_1',
      nombre: 'Favoritos de Ximena',
      descripcion: 'Las mejores canciones seleccionadas con cariño.',
      usuarioId: 'mock_admin_uid_123',
      cancionesIds: ['song_1', 'song_3', 'song_5', 'song_6', 'song_8', 'song_11'],
    ),
    PlaylistModel(
      playlistId: 'playlist_2',
      nombre: 'Éxitos Acústicos',
      descripcion: 'Para relajarse y disfrutar del sonido instrumental.',
      usuarioId: 'mock_user_uid_123',
      cancionesIds: ['song_2', 'song_4', 'song_7', 'song_9', 'song_10'],
    ),
  ];

  // --- CANCIONES ---

  Future<List<CancionModel>> getCanciones() async {
    if (!FirebaseService.isFirebaseAvailable) {
      debugPrint("Retrieving mock songs list (Offline).");
      return List.from(mockCanciones);
    }

    try {
      final snapshot = await _firestore.collection('canciones').get();
      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore 'canciones' is empty. Falling back to local mock data.");
        return List.from(mockCanciones);
      }
      return snapshot.docs.map((doc) => CancionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching songs from Firebase: $e. Falling back to local data.");
      return List.from(mockCanciones);
    }
  }

  Stream<List<CancionModel>> streamCanciones() {
    if (!FirebaseService.isFirebaseAvailable) {
      return Stream.value(List.from(mockCanciones));
    }
    return _firestore.collection('canciones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CancionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> agregarCancion(CancionModel cancion) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final id = 'song_${DateTime.now().millisecondsSinceEpoch}';
      final newCancion = CancionModel(
        cancionId: id,
        titulo: cancion.titulo,
        artista: cancion.artista,
        album: cancion.album,
        duracion: cancion.duracion <= 0 ? 200 : cancion.duracion,
        audioUrl: cancion.audioUrl.isEmpty
            ? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
            : cancion.audioUrl,
        imagenUrl: cancion.imagenUrl.isEmpty
            ? 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300'
            : cancion.imagenUrl,
      );
      mockCanciones.add(newCancion);
      return;
    }

    try {
      await _firestore.collection('canciones').add(cancion.toMap());
    } catch (e) {
      throw Exception("Error al agregar canción: $e");
    }
  }

  Future<void> editarCancion(CancionModel cancion) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final index = mockCanciones.indexWhere((c) => c.cancionId == cancion.cancionId);
      if (index != -1) {
        mockCanciones[index] = cancion;
      }
      return;
    }

    try {
      await _firestore.collection('canciones').doc(cancion.cancionId).update(cancion.toMap());
    } catch (e) {
      throw Exception("Error al editar canción: $e");
    }
  }

  Future<void> eliminarCancion(String cancionId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      mockCanciones.removeWhere((c) => c.cancionId == cancionId);
      // Remove from all playlists too
      for (var playlist in mockPlaylists) {
        playlist.cancionesIds.remove(cancionId);
      }
      return;
    }

    try {
      await _firestore.collection('canciones').doc(cancionId).delete();
      // Wait, let's also remove this song from any playlist document in Firebase if necessary
    } catch (e) {
      throw Exception("Error al eliminar canción: $e");
    }
  }

  // --- PLAYLISTS ---

  Future<List<PlaylistModel>> getPlaylists(String usuarioId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      return mockPlaylists.where((p) => p.usuarioId == usuarioId).toList();
    }

    try {
      final snapshot = await _firestore
          .collection('playlists')
          .where('usuarioId', isEqualTo: usuarioId)
          .get();
      return snapshot.docs.map((doc) => PlaylistModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching playlists from Firebase: $e");
      return mockPlaylists.where((p) => p.usuarioId == usuarioId).toList();
    }
  }

  Future<void> editarPlaylist(PlaylistModel playlist) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final index = mockPlaylists.indexWhere((p) => p.playlistId == playlist.playlistId);
      if (index != -1) {
        mockPlaylists[index] = playlist;
      }
      return;
    }

    try {
      await _firestore.collection('playlists').doc(playlist.playlistId).update(playlist.toMap());
    } catch (e) {
      throw Exception("Error al editar playlist: $e");
    }
  }

  Stream<List<PlaylistModel>> streamPlaylists(String usuarioId) {
    if (!FirebaseService.isFirebaseAvailable) {
      return Stream.value(mockPlaylists.where((p) => p.usuarioId == usuarioId).toList());
    }
    return _firestore
        .collection('playlists')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PlaylistModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> crearPlaylist(PlaylistModel playlist) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final id = 'playlist_${DateTime.now().millisecondsSinceEpoch}';
      final newPlaylist = PlaylistModel(
        playlistId: id,
        nombre: playlist.nombre,
        descripcion: playlist.descripcion,
        usuarioId: playlist.usuarioId,
        cancionesIds: playlist.cancionesIds,
      );
      mockPlaylists.add(newPlaylist);
      return;
    }

    try {
      await _firestore.collection('playlists').add(playlist.toMap());
    } catch (e) {
      throw Exception("Error al crear playlist: $e");
    }
  }

  Future<void> agregarCancionAPlaylist(String playlistId, String cancionId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final index = mockPlaylists.indexWhere((p) => p.playlistId == playlistId);
      if (index != -1 && !mockPlaylists[index].cancionesIds.contains(cancionId)) {
        mockPlaylists[index].cancionesIds.add(cancionId);
      }
      return;
    }

    try {
      await _firestore.collection('playlists').doc(playlistId).update({
        'cancionesIds': FieldValue.arrayUnion([cancionId])
      });
    } catch (e) {
      throw Exception("Error al agregar canción a la playlist: $e");
    }
  }

  Future<void> eliminarCancionDePlaylist(String playlistId, String cancionId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      final index = mockPlaylists.indexWhere((p) => p.playlistId == playlistId);
      if (index != -1) {
        mockPlaylists[index].cancionesIds.remove(cancionId);
      }
      return;
    }

    try {
      await _firestore.collection('playlists').doc(playlistId).update({
        'cancionesIds': FieldValue.arrayRemove([cancionId])
      });
    } catch (e) {
      throw Exception("Error al eliminar canción de la playlist: $e");
    }
  }

  Future<void> eliminarPlaylist(String playlistId) async {
    if (!FirebaseService.isFirebaseAvailable) {
      mockPlaylists.removeWhere((p) => p.playlistId == playlistId);
      return;
    }

    try {
      await _firestore.collection('playlists').doc(playlistId).delete();
    } catch (e) {
      throw Exception("Error al eliminar playlist: $e");
    }
  }

  Future<List<PlaylistModel>> getAllPlaylists() async {
    if (!FirebaseService.isFirebaseAvailable) {
      return List.from(mockPlaylists);
    }
    try {
      final snapshot = await _firestore.collection('playlists').get();
      return snapshot.docs.map((doc) => PlaylistModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching all playlists: $e");
      return List.from(mockPlaylists);
    }
  }
}
