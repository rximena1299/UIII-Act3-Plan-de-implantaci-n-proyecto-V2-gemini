import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  UsuarioModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UsuarioModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.rol == 'admin';

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.getCurrentUser();
      if (_currentUser != null) {
        // Try populating if authenticated but firestore was empty
        FirebaseService.checkAndPopulateFirestore();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _currentUser = await _authRepository.login(email, password);
      if (_currentUser != null) {
        await FirebaseService.checkAndPopulateFirestore();
      }
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String nombre, String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _currentUser = await _authRepository.register(nombre, email, password);
      if (_currentUser != null) {
        await FirebaseService.checkAndPopulateFirestore();
      }
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _currentUser = await _authRepository.loginWithGoogle();
      if (_currentUser != null) {
        await FirebaseService.checkAndPopulateFirestore();
      }
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
