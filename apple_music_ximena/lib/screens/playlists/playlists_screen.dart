import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/music_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/playlist_model.dart';
import '../../models/cancion_model.dart';
import '../../widgets/loading_widget.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<PlaylistProvider>(context, listen: false).fetchPlaylists(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showCreateDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          title: const Text("Crear Nueva Playlist", style: TextStyle(color: AppColors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  labelStyle: TextStyle(color: AppColors.greyText),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryPink)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  labelStyle: TextStyle(color: AppColors.greyText),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryPink)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                _descController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancelar", style: TextStyle(color: AppColors.greyText)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty) {
                  final provider = Provider.of<PlaylistProvider>(context, listen: false);
                  await provider.crearPlaylist(
                    _nameController.text.trim(),
                    _descController.text.trim(),
                    userId,
                  );
                  _nameController.clear();
                  _descController.clear();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );
  }

  void _openPlaylistDetails(PlaylistModel playlist, List<CancionModel> allSongs, MusicProvider musicProvider, String userId) {
    // Filter songs belonging to this playlist
    final playlistSongs = allSongs
        .where((song) => playlist.cancionesIds.contains(song.cancionId))
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
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.nombre,
                                  style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                if (playlist.descripcion.isNotEmpty)
                                  Text(
                                    playlist.descripcion,
                                    style: const TextStyle(color: AppColors.greyText, fontSize: 14),
                                  ),
                              ],
                            ),
                          ),
                          // Delete playlist option
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () async {
                              final provider = Provider.of<PlaylistProvider>(context, listen: false);
                              await provider.eliminarPlaylist(playlist.playlistId, userId);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Playlist eliminada con éxito."), backgroundColor: AppColors.success),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Play all button
                      if (playlistSongs.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            musicProvider.selectQueue(playlistSongs, 0);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text("Reproducir Todo"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPink,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Songs List
                      Expanded(
                        child: playlistSongs.isEmpty
                            ? const Center(
                                child: Text("Esta playlist no tiene canciones aún.", style: TextStyle(color: AppColors.greyText)),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: playlistSongs.length,
                                itemBuilder: (context, index) {
                                  final song = playlistSongs[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        song.imagenUrl,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(song.titulo, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Text(song.artista, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                      onPressed: () async {
                                        final provider = Provider.of<PlaylistProvider>(context, listen: false);
                                        await provider.eliminarCancionDePlaylist(playlist.playlistId, song.cancionId, userId);
                                        setModalState(() {
                                          playlistSongs.removeAt(index);
                                          playlist.cancionesIds.remove(song.cancionId);
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      musicProvider.playSong(song, customQueue: playlistSongs);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Inicia sesión para ver tus playlists.")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(user.uid),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: playlistProvider.isLoading
            ? const LoadingWidget(message: 'Cargando tus playlists...')
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Playlists",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p20),
                    Expanded(
                      child: playlistProvider.playlists.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.library_music_outlined, color: AppColors.greyText.withValues(alpha: 0.5), size: 64),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No tienes playlists creadas.",
                                    style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Crea una usando el botón de abajo.",
                                    style: TextStyle(color: AppColors.greyText, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: playlistProvider.playlists.length,
                              itemBuilder: (context, index) {
                                final playlist = playlistProvider.playlists[index];
                                return GestureDetector(
                                  onTap: () => _openPlaylistDetails(playlist, musicProvider.canciones, musicProvider, user.uid),
                                  child: Card(
                                    color: AppColors.secondaryBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r16)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(AppSizes.p12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Grid grid mockup of images inside the playlist cover
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius: BorderRadius.circular(AppSizes.r12),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.music_note, color: AppColors.primaryPink, size: 40),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            playlist.nombre,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            "${playlist.cancionesIds.length} canciones",
                                            style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
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
