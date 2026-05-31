import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    if (!FirebaseService.isFirebaseAvailable) {
      debugPrint("Firebase not available. Returning placeholder image URL.");
      // Return a premium unsplash image as placeholder
      return "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop";
    }

    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop";
    }
  }
}
