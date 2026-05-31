import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../../repositories/artista_repository.dart';
import '../../repositories/music_repository.dart';

class FirebaseService {
  static bool _isFirebaseAvailable = false;

  static bool get isFirebaseAvailable => _isFirebaseAvailable;

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // In production/local android if google-services.json is missing it will fail.
      // We wrap it in a try-catch to allow the app to run in mock mode.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseAvailable = true;
      debugPrint("Firebase initialized successfully.");
      
      // Auto-populate firestore with mock data if it is empty
      await checkAndPopulateFirestore();
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint("Firebase failed to initialize. Running in Local/Mock Mode. Error: $e");
    }
  }

  static Future<void> checkAndPopulateFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Populate Artistas
      for (var artista in ArtistaRepository.mockArtistas) {
        final doc = await firestore.collection('artistas').doc(artista.artistaId).get();
        if (!doc.exists) {
          debugPrint("Artist ${artista.nombreArtistico} is missing in Firestore. Populating...");
          await firestore.collection('artistas').doc(artista.artistaId).set(artista.toMap());
        }
      }

      // 2. Populate Canciones
      for (var cancion in MusicRepository.mockCanciones) {
        final doc = await firestore.collection('canciones').doc(cancion.cancionId).get();
        if (!doc.exists) {
          debugPrint("Song ${cancion.titulo} is missing in Firestore. Populating...");
          await firestore.collection('canciones').doc(cancion.cancionId).set(cancion.toMap());
        }
      }

      // 3. Populate Playlists
      for (var playlist in MusicRepository.mockPlaylists) {
        final doc = await firestore.collection('playlists').doc(playlist.playlistId).get();
        if (!doc.exists) {
          debugPrint("Playlist ${playlist.nombre} is missing in Firestore. Populating...");
          await firestore.collection('playlists').doc(playlist.playlistId).set(playlist.toMap());
        }
      }

      // 4. Populate default Admin user profile in Firestore
      final usersSnapshot = await firestore.collection('usuarios').doc('mock_admin_uid_andrea').get();
      if (!usersSnapshot.exists) {
        debugPrint("Firestore default admin is missing. Populating default admin...");
        final adminUser = {
          'uid': 'mock_admin_uid_andrea',
          'nombre': 'Andrea Montoya (Admin)',
          'email': 'andrea.montoya.her128@gmail.com',
          'foto': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
          'fechaRegistro': DateTime.now().toIso8601String(),
          'rol': 'admin',
        };
        await firestore.collection('usuarios').doc('mock_admin_uid_andrea').set(adminUser);
      }
      debugPrint("Firestore check/populate completed successfully.");
    } catch (e) {
      debugPrint("Error auto-populating Firestore: $e");
    }
  }
}
