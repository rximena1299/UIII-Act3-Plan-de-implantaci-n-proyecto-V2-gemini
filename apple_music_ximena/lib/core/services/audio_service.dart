import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // Streams for state tracking
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<double> get volumeStream => _player.volumeStream;
  Stream<bool> get shuffleModeEnabledStream => _player.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  // Getters
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get volume => _player.volume;
  bool get isShuffleModeEnabled => _player.shuffleModeEnabled;
  LoopMode get loopMode => _player.loopMode;

  Future<void> setUrl(String url) async {
    try {
      // In case we are using mock/local files or invalid test URLs:
      if (url.isEmpty || !url.startsWith('http')) {
        // Fallback or local asset if necessary.
        // We will load a royalty-free test mp3 for testing offline.
        await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      } else {
        await _player.setUrl(url);
      }
    } catch (e) {
      debugPrint("Error loading audio URL: $e. Falling back to test song.");
      try {
        await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3');
      } catch (e2) {
        debugPrint("Error loading fallback audio: $e2");
      }
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
