import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/services/audio_service.dart';
import '../models/cancion_model.dart';
import '../repositories/music_repository.dart';

class MusicProvider with ChangeNotifier {
  final MusicRepository _musicRepository = MusicRepository();
  final AudioService _audioService = AudioService();

  List<CancionModel> _canciones = [];
  List<CancionModel> _queue = [];
  int _currentIndex = -1;
  bool _isLoading = false;
  String _errorMessage = '';

  // Audio state properties
  PlayerState? _playerState;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.8;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  // Stream subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _volumeSubscription;

  // Getters
  List<CancionModel> get canciones => _canciones;
  List<CancionModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  CancionModel? get currentCancion => (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  PlayerState? get playerState => _playerState;
  bool get isPlaying => _playerState?.playing ?? false;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;

  MusicProvider() {
    fetchSongs();
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      _playerState = state;
      // Auto-play next song when current finishes
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });

    _positionSubscription = _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSubscription = _audioService.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _volumeSubscription = _audioService.volumeStream.listen((vol) {
      _volume = vol;
      notifyListeners();
    });
  }

  Future<void> fetchSongs() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _canciones = await _musicRepository.getCanciones();
      if (_queue.isEmpty && _canciones.isNotEmpty) {
        _queue = List.from(_canciones);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCancion(CancionModel cancion) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.agregarCancion(cancion);
      await fetchSongs();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarCancion(CancionModel cancion) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _musicRepository.editarCancion(cancion);
      await fetchSongs();
      // Update queue item if it's currently loaded
      final queueIdx = _queue.indexWhere((c) => c.cancionId == cancion.cancionId);
      if (queueIdx != -1) {
        _queue[queueIdx] = cancion;
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarCancion(String cancionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (currentCancion?.cancionId == cancionId) {
        await stop();
      }
      await _musicRepository.eliminarCancion(cancionId);
      await fetchSongs();
      _queue.removeWhere((c) => c.cancionId == cancionId);
      _currentIndex = _queue.indexWhere((c) => c.cancionId == currentCancion?.cancionId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- PLAYBACK CONTROLS ---

  Future<void> playSong(CancionModel song, {List<CancionModel>? customQueue}) async {
    if (customQueue != null) {
      _queue = List.from(customQueue);
    } else if (_queue.isEmpty) {
      _queue = List.from(_canciones);
    }

    final index = _queue.indexWhere((c) => c.cancionId == song.cancionId);
    _currentIndex = index != -1 ? index : 0;

    notifyListeners();

    try {
      await _audioService.setUrl(song.audioUrl);
      await _audioService.play();
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  Future<void> selectQueue(List<CancionModel> newQueue, int startIndex) async {
    if (newQueue.isEmpty) return;
    _queue = List.from(newQueue);
    _currentIndex = startIndex;
    notifyListeners();
    await playSong(_queue[_currentIndex]);
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      await _audioService.pause();
    } else {
      if (_currentIndex == -1 && _queue.isNotEmpty) {
        _currentIndex = 0;
        await playSong(_queue[_currentIndex]);
      } else {
        await _audioService.play();
      }
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_isShuffle) {
      // Pick random
      _currentIndex = (DateTime.now().millisecondsSinceEpoch) % _queue.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    notifyListeners();
    await playSong(_queue[_currentIndex]);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
    } else {
      _currentIndex = _queue.length - 1;
    }
    notifyListeners();
    await playSong(_queue[_currentIndex]);
  }

  Future<void> setVolume(double val) async {
    _volume = val;
    await _audioService.setVolume(val);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffle = !_isShuffle;
    await _audioService.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  Future<void> toggleLoopMode() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    await _audioService.setLoopMode(_loopMode);
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _volumeSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
