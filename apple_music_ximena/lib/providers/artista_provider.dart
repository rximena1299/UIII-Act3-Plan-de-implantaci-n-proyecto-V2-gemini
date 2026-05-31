import 'package:flutter/material.dart';
import '../models/artista_model.dart';
import '../repositories/artista_repository.dart';

class ArtistaProvider with ChangeNotifier {
  final ArtistaRepository _artistaRepository = ArtistaRepository();

  List<ArtistaModel> _artistas = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ArtistaModel> get artistas => _artistas;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  ArtistaProvider() {
    fetchArtistas();
  }

  Future<void> fetchArtistas() async {
    _isLoading = true;
    _errorMessage = '';
    // Optional: we can defer notification during construction
    notifyListeners();
    try {
      _artistas = await _artistaRepository.getArtistas();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarArtista(ArtistaModel artista) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _artistaRepository.agregarArtista(artista);
      await fetchArtistas(); // Refresh local list
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarArtista(ArtistaModel artista) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _artistaRepository.editarArtista(artista);
      await fetchArtistas(); // Refresh local list
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarArtista(String artistaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _artistaRepository.eliminarArtista(artistaId);
      await fetchArtistas(); // Refresh local list
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
