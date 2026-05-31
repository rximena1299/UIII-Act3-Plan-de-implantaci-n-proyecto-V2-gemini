import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../repositories/music_repository.dart';

class PlaylistProvider with ChangeNotifier {
  final MusicRepository _musicRepository = MusicRepository();

  List<PlaylistModel> _playlists = [];
  List<PlaylistModel> _allPlaylists = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<PlaylistModel> get playlists => _playlists;
  List<PlaylistModel> get allPlaylists => _allPlaylists;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchAllPlaylists() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _allPlaylists = await _musicRepository.getAllPlaylists();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> crearPlaylistAdmin(String nombre, String descripcion, String usuarioId, {List<String> cancionesIds = const []}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPlaylist = PlaylistModel(
        playlistId: '',
        nombre: nombre,
        descripcion: descripcion,
        usuarioId: usuarioId,
        cancionesIds: cancionesIds,
      );
      await _musicRepository.crearPlaylist(newPlaylist);
      await fetchAllPlaylists();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarPlaylistAdmin(PlaylistModel playlist) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.editarPlaylist(playlist);
      await fetchAllPlaylists();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarPlaylistAdmin(String playlistId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.eliminarPlaylist(playlistId);
      await fetchAllPlaylists();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlaylists(String usuarioId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _playlists = await _musicRepository.getPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> crearPlaylist(String nombre, String descripcion, String usuarioId, {List<String> cancionesIds = const []}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPlaylist = PlaylistModel(
        playlistId: '',
        nombre: nombre,
        descripcion: descripcion,
        usuarioId: usuarioId,
        cancionesIds: cancionesIds,
      );
      await _musicRepository.crearPlaylist(newPlaylist);
      await fetchPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarPlaylist(PlaylistModel playlist, String usuarioId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.editarPlaylist(playlist);
      await fetchPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCancionAPlaylist(String playlistId, String cancionId, String usuarioId) async {
    try {
      await _musicRepository.agregarCancionAPlaylist(playlistId, cancionId);
      await fetchPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> eliminarCancionDePlaylist(String playlistId, String cancionId, String usuarioId) async {
    try {
      await _musicRepository.eliminarCancionDePlaylist(playlistId, cancionId);
      await fetchPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> eliminarPlaylist(String playlistId, String usuarioId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.eliminarPlaylist(playlistId);
      await fetchPlaylists(usuarioId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
