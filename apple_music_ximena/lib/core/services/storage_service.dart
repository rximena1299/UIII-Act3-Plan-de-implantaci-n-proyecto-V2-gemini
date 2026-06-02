import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage.
  /// [file] can be a `File` (on mobile/desktop) or `Uint8List` / `XFile` (on Web).
  Future<String> uploadImage(dynamic file, String path) async {
    if (!FirebaseService.isFirebaseAvailable) {
      debugPrint("Firebase not available. Returning placeholder image URL.");
      // Return a premium unsplash image as placeholder
      return "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop";
    }

    try {
      final ref = _storage.ref().child(path);
      UploadTask uploadTask;

      if (kIsWeb) {
        if (file is Uint8List) {
          uploadTask = ref.putData(file);
        } else {
          // Attempt to call readAsBytes if it's an XFile or similar cross-platform file
          final bytes = await file.readAsBytes();
          uploadTask = ref.putData(bytes);
        }
      } else {
        // On native platforms, we cast to dart:io File
        // We import dart:io dynamically or use the putFile method which is only available on native
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop";
    }
  }
}
