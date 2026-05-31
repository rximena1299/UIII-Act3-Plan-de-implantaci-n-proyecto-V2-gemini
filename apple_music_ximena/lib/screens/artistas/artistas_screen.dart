import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artista_provider.dart';
import '../../providers/music_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/artista_model.dart';
import '../../widgets/loading_widget.dart';

class ArtistasScreen extends StatefulWidget {
  const ArtistasScreen({super.key});

  @override
  State<ArtistasScreen> createState() => _ArtistasScreenState();
}

class _ArtistasScreenState extends State<ArtistasScreen> {
  void _openArtistDetails(ArtistaModel artist, MusicProvider musicProvider) {
    // Filter songs by this artist
    final artistSongs = musicProvider.canciones
        .where((song) => song.artista.toLowerCase() == artist.nombreArtistico.toLowerCase())
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.greyText.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.r16),
                        child: Image.network(
                          artist.imagenUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist.nombreArtistico,
                              style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Nombre Real: ${artist.nombreReal}",
                              style: const TextStyle(color: AppColors.greyText, fontSize: 13),
                            ),
                            Text(
                              "Origen: ${artist.paisOrigen}",
                              style: const TextStyle(color: AppColors.greyText, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Biografía",
                    style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.biografia,
                    style: const TextStyle(color: AppColors.greyText, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Canciones de ${artist.nombreArtistico}",
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  artistSongs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text("No hay canciones disponibles de este artista.", style: TextStyle(color: AppColors.greyText)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: artistSongs.length,
                          itemBuilder: (context, index) {
                            final song = artistSongs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  song.imagenUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(song.titulo, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(song.album, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
                              trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryPink),
                              onTap: () {
                                musicProvider.playSong(song, customQueue: artistSongs);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistaProvider = Provider.of<ArtistaProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: artistaProvider.isLoading
            ? const LoadingWidget(message: 'Cargando artistas...')
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Artistas",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p20),
                    Expanded(
                      child: artistaProvider.artistas.isEmpty
                          ? const Center(
                              child: Text(
                                "No hay artistas registrados.",
                                style: TextStyle(color: AppColors.greyText, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: artistaProvider.artistas.length,
                              itemBuilder: (context, index) {
                                final artist = artistaProvider.artistas[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSizes.p12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBackground,
                                    borderRadius: BorderRadius.circular(AppSizes.r16),
                                    border: Border.all(color: AppColors.glassBorder, width: 0.5),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(AppSizes.p8),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(artist.imagenUrl),
                                      backgroundColor: AppColors.background,
                                    ),
                                    title: Text(
                                      artist.nombreArtistico,
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      artist.paisOrigen,
                                      style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryPink, size: 16),
                                    onTap: () => _openArtistDetails(artist, musicProvider),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 80), // Bottom padding for floating mini player
                  ],
                ),
              ),
      ),
    );
  }
}
