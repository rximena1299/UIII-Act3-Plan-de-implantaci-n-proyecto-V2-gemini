import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/music_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final currentSong = musicProvider.currentCancion;

    // Only show mini player if a song is selected/playing
    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    // Get duration and position fractions for progress
    final double progress = musicProvider.duration.inSeconds > 0
        ? (musicProvider.position.inSeconds / musicProvider.duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        context.push('/reproductor');
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(color: AppColors.glassBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Stack(
            children: [
              // Linear Progress Indicator along the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                  minHeight: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
                child: Row(
                  children: [
                    // Album Cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                      child: CachedNetworkImage(
                        imageUrl: currentSong.imagenUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.background,
                          child: const Icon(Icons.music_note, color: AppColors.primaryPink),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    // Titles
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            currentSong.artista,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Controls
                    IconButton(
                      icon: Icon(
                        musicProvider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppColors.primaryPink,
                        size: 32,
                      ),
                      onPressed: () {
                        musicProvider.togglePlay();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        musicProvider.next();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
