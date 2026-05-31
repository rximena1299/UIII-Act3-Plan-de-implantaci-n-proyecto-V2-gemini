import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/music_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class ReproductorScreen extends StatefulWidget {
  const ReproductorScreen({super.key});

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _artworkController;
  double _dragValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    // Sync artwork rotation with music playing state
    final provider = Provider.of<MusicProvider>(context, listen: false);
    if (provider.isPlaying) {
      _artworkController.repeat();
    }
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final song = musicProvider.currentCancion;

    // Direct animation control
    if (musicProvider.isPlaying) {
      if (!_artworkController.isAnimating) {
        _artworkController.repeat();
      }
    } else {
      if (_artworkController.isAnimating) {
        _artworkController.stop();
      }
    }

    if (song == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text("Reproductor")),
        body: const Center(
          child: Text(
            "Ninguna canción en reproducción.",
            style: TextStyle(color: AppColors.greyText, fontSize: 16),
          ),
        ),
      );
    }

    // Get durations
    final currentPos = musicProvider.position;
    final totalDuration = musicProvider.duration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Blurred Background of the Cover
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(song.imagenUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p12),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          const Text(
                            "REPRODUCIENDO DESDE",
                            style: TextStyle(color: AppColors.greyText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Text(
                            song.album,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48), // Spacer to balance back button
                    ],
                  ),

                  const Spacer(),

                  // Animated Circular Artwork
                  AnimatedBuilder(
                    animation: _artworkController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _artworkController.value * 2 * 3.1415926,
                        child: child,
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: MediaQuery.of(context).size.width * 0.65,
                      constraints: const BoxConstraints(maxHeight: 280, maxWidth: 280),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.35),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(song.imagenUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Song Title & Artist Details
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          song.artista,
                          style: const TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // Progress Bar & Durations
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: AppColors.white,
                          inactiveTrackColor: AppColors.white.withValues(alpha: 0.2),
                          thumbColor: AppColors.white,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: totalDuration.inSeconds.toDouble() > 0
                              ? totalDuration.inSeconds.toDouble()
                              : 100.0,
                          value: _isDragging
                              ? _dragValue
                              : currentPos.inSeconds.toDouble().clamp(
                                  0.0,
                                  totalDuration.inSeconds.toDouble() > 0
                                      ? totalDuration.inSeconds.toDouble()
                                      : 100.0,
                                ),
                          onChanged: (value) {
                            setState(() {
                              _isDragging = true;
                              _dragValue = value;
                            });
                          },
                          onChangeEnd: (value) {
                            musicProvider.seek(Duration(seconds: value.toInt()));
                            setState(() {
                              _isDragging = false;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_isDragging ? Duration(seconds: _dragValue.toInt()) : currentPos),
                              style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(totalDuration),
                              style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.p16),

                  // Playback controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle button
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: musicProvider.isShuffle ? AppColors.primaryPink : AppColors.white.withValues(alpha: 0.5),
                          size: 24,
                        ),
                        onPressed: () => musicProvider.toggleShuffle(),
                      ),
                      // Skip Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: AppColors.white, size: 40),
                        onPressed: () => musicProvider.previous(),
                      ),
                      // Play/Pause
                      IconButton(
                        icon: Icon(
                          musicProvider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: AppColors.white,
                          size: 72,
                        ),
                        onPressed: () => musicProvider.togglePlay(),
                      ),
                      // Skip Next
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: AppColors.white, size: 40),
                        onPressed: () => musicProvider.next(),
                      ),
                      // Loop mode
                      IconButton(
                        icon: Icon(
                          musicProvider.loopMode == LoopMode.one
                              ? Icons.repeat_one
                              : musicProvider.loopMode == LoopMode.all
                                  ? Icons.repeat
                                  : Icons.repeat,
                          color: musicProvider.loopMode != LoopMode.off
                              ? AppColors.primaryPink
                              : AppColors.white.withValues(alpha: 0.5),
                          size: 24,
                        ),
                        onPressed: () => musicProvider.toggleLoopMode(),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Volume Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.volume_mute, color: AppColors.white.withValues(alpha: 0.5), size: 18),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              activeTrackColor: AppColors.white.withValues(alpha: 0.8),
                              inactiveTrackColor: AppColors.white.withValues(alpha: 0.15),
                              thumbColor: AppColors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                            ),
                            child: Slider(
                              value: musicProvider.volume,
                              onChanged: (val) {
                                musicProvider.setVolume(val);
                              },
                            ),
                          ),
                        ),
                        Icon(Icons.volume_up, color: AppColors.white.withValues(alpha: 0.8), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
