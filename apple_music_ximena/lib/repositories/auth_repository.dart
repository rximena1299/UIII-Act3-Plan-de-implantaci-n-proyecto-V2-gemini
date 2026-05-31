import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // In-memory mock storage for offline mode
  static final Map<String, Map<String, dynamic>> mockUsers = {
    'admin@ximena.com': {
      'uid': 'mock_admin_uid_123',
      'nombre': 'Ximena Reyes (Admin)',
      'email': 'admin@ximena.com',
      'foto': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      'fechaRegistro': DateTime.now().toIso8601String(),
      'rol': 'admin',
      'password': 'password123',
    },
    'andrea.montoya.her128@gmail.com': {
      'uid': 'mock_admin_uid_andrea',
      'nombre': 'Andrea Montoya (Admin)',
      'email': 'andrea.montoya.her128@gmail.com',
      'foto': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      'fechaRegistro': DateTime.now().toIso8601String(),
      'rol': 'admin',
      'password': 'password123',
    },
    'user@ximena.com': {
      'uid': 'mock_user_uid_123',
      'nombre': 'Andrea User',
      'email': 'user@ximena.com',
      'foto': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'fechaRegistro': DateTime.now().toIso8601String(),
      'rol': 'user',
      'password': 'password123',
    }
  };

  // Helper to persist logged in state locally
  Future<UsuarioModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_email');
    if (email != null && mockUsers.containsKey(email)) {
      final data = mockUsers[email]!;
      return UsuarioModel.fromMap(data, data['uid']);
    }
    return null;
  }

  Future<void> saveLoggedUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_email', email);
  }

  Future<void> clearLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_email');
  }

  Future<UsuarioModel?> login(String email, String password) async {
    if (!FirebaseService.isFirebaseAvailable) {
      // Local check
      if (mockUsers.containsKey(email)) {
        final mockUser = mockUsers[email]!;
        if (mockUser['password'] == password) {
          await saveLoggedUser(email);
          return UsuarioModel.fromMap(mockUser, mockUser['uid']);
        }
      }
      throw Exception("Correo o contraseña incorrectos (Modo Offline).");
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final doc = await _firestore.collection('usuarios').doc(credential.user!.uid).get();
        if (doc.exists) {
          return UsuarioModel.fromMap(doc.data()!, doc.id);
        } else {
          // If profile doc doesn't exist, create default
          final newUser = UsuarioModel(
            uid: credential.user!.uid,
            nombre: credential.user!.displayName ?? email.split('@')[0],
            email: email,
            fechaRegistro: DateTime.now(),
            rol: 'user',
          );
          await _firestore.collection('usuarios').doc(credential.user!.uid).set(newUser.toMap());
          return newUser;
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Error al iniciar sesión.");
    }
    return null;
  }

  Future<UsuarioModel?> register(String nombre, String email, String password) async {
    if (!FirebaseService.isFirebaseAvailable) {
      if (mockUsers.containsKey(email)) {
        throw Exception("El correo electrónico ya está registrado.");
      }
      final uid = 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';
      final newUserData = {
        'uid': uid,
        'nombre': nombre,
        'email': email,
        'foto': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        'fechaRegistro': DateTime.now().toIso8601String(),
        'rol': (email.contains('admin') || email == 'andrea.montoya.her128@gmail.com') ? 'admin' : 'user',
        'password': password,
      };
      mockUsers[email] = newUserData;
      await saveLoggedUser(email);
      return UsuarioModel.fromMap(newUserData, uid);
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final newUser = UsuarioModel(
          uid: credential.user!.uid,
          nombre: nombre,
          email: email,
          fechaRegistro: DateTime.now(),
          rol: (email.contains('admin') || email == 'andrea.montoya.her128@gmail.com') ? 'admin' : 'user',
        );
        await _firestore.collection('usuarios').doc(credential.user!.uid).set(newUser.toMap());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Error al registrarse.");
    }
    return null;
  }

  Future<UsuarioModel?> loginWithGoogle() async {
    if (!FirebaseService.isFirebaseAvailable) {
      // Simulate Google Sign-In with standard admin user
      final mockEmail = 'admin@ximena.com';
      await saveLoggedUser(mockEmail);
      return UsuarioModel.fromMap(mockUsers[mockEmail]!, mockUsers[mockEmail]!['uid']);
    }

    try {
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInClientAuthorization authz = await googleUser.authorizationClient.authorizeScopes([]);
      final credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final doc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          return UsuarioModel.fromMap(doc.data()!, doc.id);
        } else {
          final newUser = UsuarioModel(
            uid: userCredential.user!.uid,
            nombre: userCredential.user!.displayName ?? 'Google User',
            email: userCredential.user!.email ?? '',
            foto: userCredential.user!.photoURL ?? '',
            fechaRegistro: DateTime.now(),
            rol: (userCredential.user!.email == 'andrea.montoya.her128@gmail.com' || (userCredential.user!.email?.contains('admin') ?? false)) ? 'admin' : 'user',
          );
          await _firestore.collection('usuarios').doc(userCredential.user!.uid).set(newUser.toMap());
          return newUser;
        }
      }
    } catch (e) {
      throw Exception("Error al iniciar sesión con Google: $e");
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    if (!FirebaseService.isFirebaseAvailable) {
      if (!mockUsers.containsKey(email)) {
        throw Exception("El correo no se encuentra registrado.");
      }
      return; // Simulated email sent.
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Error al enviar el correo de recuperación.");
    }
  }

  Future<void> logout() async {
    await clearLoggedUser();
    if (FirebaseService.isFirebaseAvailable) {
      await _auth.signOut();
      await _googleSignIn.signOut();
    }
  }

  Future<UsuarioModel?> getCurrentUser() async {
    if (!FirebaseService.isFirebaseAvailable) {
      return await getSavedUser();
    }

    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        return UsuarioModel.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  // --- USER MANAGEMENT FOR ADMINS ---

  Future<List<UsuarioModel>> getUsuarios() async {
    if (!FirebaseService.isFirebaseAvailable) {
      return mockUsers.values.map((data) => UsuarioModel.fromMap(data, data['uid'])).toList();
    }
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      return snapshot.docs.map((doc) => UsuarioModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching users from Firebase: $e");
      return mockUsers.values.map((data) => UsuarioModel.fromMap(data, data['uid'])).toList();
    }
  }

  Future<void> actualizarRolUsuario(String uid, String rol) async {
    if (!FirebaseService.isFirebaseAvailable) {
      for (var key in mockUsers.keys) {
        if (mockUsers[key]!['uid'] == uid) {
          mockUsers[key]!['rol'] = rol;
          break;
        }
      }
      return;
    }
    try {
      await _firestore.collection('usuarios').doc(uid).update({'rol': rol});
    } catch (e) {
      throw Exception("Error al actualizar rol de usuario: $e");
    }
  }

  Future<void> eliminarUsuario(String uid) async {
    if (!FirebaseService.isFirebaseAvailable) {
      mockUsers.removeWhere((key, val) => val['uid'] == uid);
      return;
    }
    try {
      await _firestore.collection('usuarios').doc(uid).delete();
    } catch (e) {
      throw Exception("Error al eliminar usuario: $e");
    }
  }
}
