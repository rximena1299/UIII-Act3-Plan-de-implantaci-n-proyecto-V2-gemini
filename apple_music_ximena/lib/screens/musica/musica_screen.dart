import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/loading_widget.dart';

class MusicaScreen extends StatefulWidget {
  const MusicaScreen({super.key});

  @override
  State<MusicaScreen> createState() => _MusicaScreenState();
}

class _MusicaScreenState extends State<MusicaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddToPlaylistDialog(BuildContext context, String cancionId, String userId) {
    Provider.of<PlaylistProvider>(context, listen: false).fetchPlaylists(userId);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, child) {
            final userPlaylists = playlistProvider.playlists;
            return AlertDialog(
              backgroundColor: AppColors.secondaryBackground,
              title: const Text("Agregar a Playlist", style: TextStyle(color: AppColors.white)),
              content: userPlaylists.isEmpty
                  ? const Text("No tienes playlists creadas. Créalas en la pestaña de Playlists.", style: TextStyle(color: AppColors.greyText))
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: userPlaylists.length,
                        itemBuilder: (context, index) {
                          final pl = userPlaylists[index];
                          return ListTile(
                            leading: const Icon(Icons.playlist_play, color: AppColors.primaryPink),
                            title: Text(pl.nombre, style: const TextStyle(color: AppColors.white)),
                            onTap: () async {
                              await playlistProvider.agregarCancionAPlaylist(pl.playlistId, cancionId, userId);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Agregada a '${pl.nombre}' con éxito."),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar", style: TextStyle(color: AppColors.greyText)),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Filter songs based on search
    final filteredSongs = musicProvider.canciones.where((song) {
      final query = _searchQuery.toLowerCase();
      return song.titulo.toLowerCase().contains(query) ||
          song.artista.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: musicProvider.isLoading
            ? const LoadingWidget(message: 'Cargando biblioteca...')
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biblioteca",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Modern Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: "Buscar por canción, artista o álbum...",
                        hintStyle: const TextStyle(color: AppColors.greyText),
                        filled: true,
                        fillColor: AppColors.secondaryBackground,
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryPink),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.greyText),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          borderSide: const BorderSide(color: AppColors.primaryPink, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // Track count
                    Text(
                      "${filteredSongs.length} canciones encontradas",
                      style: const TextStyle(color: AppColors.greyText, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Songs List
                    Expanded(
                      child: filteredSongs.isEmpty
                          ? const Center(
                              child: Text(
                                "No se encontraron canciones.",
                                style: TextStyle(color: AppColors.greyText, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredSongs.length,
                              itemBuilder: (context, index) {
                                final song = filteredSongs[index];
                                final isCurrent = musicProvider.currentCancion?.cancionId == song.cancionId;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSizes.p8),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.primaryPink.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppSizes.r12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p8, vertical: 4),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppSizes.r8),
                                      child: Image.network(
                                        song.imagenUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 48,
                                          height: 48,
                                          color: AppColors.secondaryBackground,
                                          child: const Icon(Icons.music_note, color: AppColors.primaryPink),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      song.titulo,
                                      style: TextStyle(
                                        color: isCurrent ? AppColors.primaryPink : AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${song.artista} • ${song.album}",
                                      style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          song.formattedDuration,
                                          style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.playlist_add, color: AppColors.greyText, size: 22),
                                          onPressed: () {
                                            if (user != null) {
                                              _showAddToPlaylistDialog(context, song.cancionId, user.uid);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Debes iniciar sesión para agregar a una playlist."), backgroundColor: AppColors.error),
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          isCurrent && musicProvider.isPlaying
                                              ? Icons.volume_up_rounded
                                              : Icons.play_arrow_rounded,
                                          color: isCurrent ? AppColors.primaryPink : AppColors.greyText,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      musicProvider.playSong(song, customQueue: filteredSongs);
                                    },
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
