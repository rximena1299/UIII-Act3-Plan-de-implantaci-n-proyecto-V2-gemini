import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artista_provider.dart';
import '../../providers/music_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/artista_model.dart';
import '../../models/cancion_model.dart';
import '../../models/playlist_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/custom_textfield.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UsuarioModel> _usuarios = [];
  bool _isLoadingUsuarios = false;

  // Controllers for Artist form
  final _artStageNameController = TextEditingController();
  final _artRealNameController = TextEditingController();
  final _artCountryController = TextEditingController();
  final _artBioController = TextEditingController();
  final _artImgController = TextEditingController();

  // Controllers for Song form
  final _songTitleController = TextEditingController();
  final _songArtistController = TextEditingController();
  final _songAlbumController = TextEditingController();
  final _songDurationController = TextEditingController();
  final _songAudioController = TextEditingController();
  final _songImgController = TextEditingController();

  // Controllers for Playlist form
  final _playlistNameController = TextEditingController();
  final _playlistDescController = TextEditingController();
  final _playlistUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsuarios();
      Provider.of<PlaylistProvider>(context, listen: false).fetchAllPlaylists();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    _artStageNameController.dispose();
    _artRealNameController.dispose();
    _artCountryController.dispose();
    _artBioController.dispose();
    _artImgController.dispose();

    _songTitleController.dispose();
    _songArtistController.dispose();
    _songAlbumController.dispose();
    _songDurationController.dispose();
    _songAudioController.dispose();
    _songImgController.dispose();

    _playlistNameController.dispose();
    _playlistDescController.dispose();
    _playlistUserController.dispose();

    super.dispose();
  }

  Future<void> _loadUsuarios() async {
    setState(() {
      _isLoadingUsuarios = true;
    });
    try {
      final repo = AuthRepository();
      final users = await repo.getUsuarios();
      setState(() {
        _usuarios = users;
      });
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      setState(() {
        _isLoadingUsuarios = false;
      });
    }
  }

  void _toggleUserRole(UsuarioModel user) async {
    final newRol = user.rol == 'admin' ? 'user' : 'admin';
    try {
      final repo = AuthRepository();
      await repo.actualizarRolUsuario(user.uid, newRol);
      await _loadUsuarios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rol de ${user.nombre} actualizado a $newRol."), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _deleteUser(UsuarioModel user) async {
    try {
      final repo = AuthRepository();
      await repo.eliminarUsuario(user.uid);
      await _loadUsuarios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado con éxito."), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showPlaylistDialog({PlaylistModel? playlist}) {
    final isEdit = playlist != null;
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final allSongs = musicProvider.canciones;
    final List<String> selectedSongIds = isEdit ? List.from(playlist.cancionesIds) : [];

    if (isEdit) {
      _playlistNameController.text = playlist.nombre;
      _playlistDescController.text = playlist.descripcion;
      _playlistUserController.text = playlist.usuarioId;
    } else {
      _playlistNameController.clear();
      _playlistDescController.clear();
      _playlistUserController.text = 'mock_admin_uid_andrea';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.secondaryBackground,
              title: Text(isEdit ? "Editar Playlist" : "Agregar Playlist", style: const TextStyle(color: AppColors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(controller: _playlistNameController, label: "Nombre"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _playlistDescController, label: "Descripción"),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _playlistUserController, label: "ID Usuario Propietario"),
                      const SizedBox(height: 16),
                      const Text(
                        "Seleccionar Canciones",
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          border: Border.all(color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: allSongs.isEmpty
                            ? const Center(
                                child: Text("No hay canciones disponibles.", style: TextStyle(color: AppColors.greyText)),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: allSongs.length,
                                itemBuilder: (context, index) {
                                  final song = allSongs[index];
                                  final isChecked = selectedSongIds.contains(song.cancionId);
                                  return CheckboxListTile(
                                    title: Text(
                                      song.titulo,
                                      style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      song.artista,
                                      style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    value: isChecked,
                                    activeColor: AppColors.primaryPink,
                                    checkColor: AppColors.white,
                                    onChanged: (bool? value) {
                                      setDialogState(() {
                                        if (value == true) {
                                          selectedSongIds.add(song.cancionId);
                                        } else {
                                          selectedSongIds.remove(song.cancionId);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: AppColors.greyText)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_playlistNameController.text.trim().isNotEmpty) {
                      final provider = Provider.of<PlaylistProvider>(context, listen: false);
                      if (isEdit) {
                        final updatedPlaylist = PlaylistModel(
                          playlistId: playlist.playlistId,
                          nombre: _playlistNameController.text.trim(),
                          descripcion: _playlistDescController.text.trim(),
                          usuarioId: _playlistUserController.text.trim(),
                          cancionesIds: selectedSongIds,
                        );
                        await provider.editarPlaylistAdmin(updatedPlaylist);
                      } else {
                        await provider.crearPlaylistAdmin(
                          _playlistNameController.text.trim(),
                          _playlistDescController.text.trim(),
                          _playlistUserController.text.trim(),
                          cancionesIds: selectedSongIds,
                        );
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? "Playlist editada con éxito." : "Playlist agregada con éxito."),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
                  child: Text(isEdit ? "Guardar" : "Agregar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- CRUD ARTIST DIALOG ---
  void _showArtistDialog({ArtistaModel? artist}) {
    final isEdit = artist != null;
    if (isEdit) {
      _artStageNameController.text = artist.nombreArtistico;
      _artRealNameController.text = artist.nombreReal;
      _artCountryController.text = artist.paisOrigen;
      _artBioController.text = artist.biografia;
      _artImgController.text = artist.imagenUrl;
    } else {
      _artStageNameController.clear();
      _artRealNameController.clear();
      _artCountryController.clear();
      _artBioController.clear();
      _artImgController.text = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          title: Text(isEdit ? "Editar Artista" : "Agregar Artista", style: const TextStyle(color: AppColors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: _artStageNameController, label: "Nombre Artístico"),
                const SizedBox(height: 12),
                CustomTextField(controller: _artRealNameController, label: "Nombre Real"),
                const SizedBox(height: 12),
                CustomTextField(controller: _artCountryController, label: "País de Origen"),
                const SizedBox(height: 12),
                CustomTextField(controller: _artBioController, label: "Biografía"),
                const SizedBox(height: 12),
                CustomTextField(controller: _artImgController, label: "URL de Imagen"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: AppColors.greyText)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_artStageNameController.text.trim().isNotEmpty) {
                  final provider = Provider.of<ArtistaProvider>(context, listen: false);
                  final newArtist = ArtistaModel(
                    artistaId: isEdit ? artist.artistaId : '',
                    nombreArtistico: _artStageNameController.text.trim(),
                    nombreReal: _artRealNameController.text.trim(),
                    paisOrigen: _artCountryController.text.trim(),
                    biografia: _artBioController.text.trim(),
                    imagenUrl: _artImgController.text.trim(),
                  );

                  if (isEdit) {
                    await provider.editarArtista(newArtist);
                  } else {
                    await provider.agregarArtista(newArtist);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? "Artista editado con éxito." : "Artista agregado con éxito."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
              child: Text(isEdit ? "Guardar" : "Agregar"),
            ),
          ],
        );
      },
    );
  }

  // --- CRUD SONG DIALOG ---
  void _showSongDialog({CancionModel? song}) {
    final isEdit = song != null;
    if (isEdit) {
      _songTitleController.text = song.titulo;
      _songArtistController.text = song.artista;
      _songAlbumController.text = song.album;
      _songDurationController.text = song.duracion.toString();
      _songAudioController.text = song.audioUrl;
      _songImgController.text = song.imagenUrl;
    } else {
      _songTitleController.clear();
      _songArtistController.clear();
      _songAlbumController.clear();
      _songDurationController.text = '240';
      _songAudioController.text = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      _songImgController.text = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          title: Text(isEdit ? "Editar Canción" : "Agregar Canción", style: const TextStyle(color: AppColors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: _songTitleController, label: "Título"),
                const SizedBox(height: 12),
                CustomTextField(controller: _songArtistController, label: "Artista"),
                const SizedBox(height: 12),
                CustomTextField(controller: _songAlbumController, label: "Álbum"),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _songDurationController,
                  label: "Duración (segundos)",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(controller: _songAudioController, label: "URL de Audio"),
                const SizedBox(height: 12),
                CustomTextField(controller: _songImgController, label: "URL de Imagen"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: AppColors.greyText)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_songTitleController.text.trim().isNotEmpty) {
                  final provider = Provider.of<MusicProvider>(context, listen: false);
                  final duration = int.tryParse(_songDurationController.text) ?? 200;
                  final newSong = CancionModel(
                    cancionId: isEdit ? song.cancionId : '',
                    titulo: _songTitleController.text.trim(),
                    artista: _songArtistController.text.trim(),
                    album: _songAlbumController.text.trim(),
                    duracion: duration,
                    audioUrl: _songAudioController.text.trim(),
                    imagenUrl: _songImgController.text.trim(),
                  );

                  if (isEdit) {
                    await provider.editarCancion(newSong);
                  } else {
                    await provider.agregarCancion(newSong);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? "Canción editada con éxito." : "Canción agregada con éxito."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
              child: Text(isEdit ? "Guardar" : "Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistProvider = Provider.of<ArtistaProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    // Calculated Statistics
    final int userCount = _usuarios.length;
    final int playlistCount = playlistProvider.allPlaylists.length;
    final int artistCount = artistProvider.artistas.length;
    final int songCount = musicProvider.canciones.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryPink),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: AppColors.greyText,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt), text: "Artistas"),
            Tab(icon: Icon(Icons.music_note), text: "Canciones"),
            Tab(icon: Icon(Icons.playlist_play), text: "Playlists"),
            Tab(icon: Icon(Icons.person), text: "Usuarios"),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Statistics Cards
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  _buildStatCard("Artistas", artistCount.toString(), Icons.people_alt, Colors.purple),
                  const SizedBox(width: 8),
                  _buildStatCard("Canciones", songCount.toString(), Icons.music_note, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatCard("Playlists", playlistCount.toString(), Icons.playlist_play, Colors.orange),
                  const SizedBox(width: 8),
                  _buildStatCard("Usuarios", userCount.toString(), Icons.person, Colors.green),
                ],
              ),
            ),

            // 2. Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- ARTISTS TAB ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Listado de Artistas", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () => _showArtistDialog(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Nuevo"),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, minimumSize: const Size(90, 36)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: artistProvider.artistas.length,
                            itemBuilder: (context, index) {
                              final artist = artistProvider.artistas[index];
                              return ListTile(
                                leading: CircleAvatar(backgroundImage: NetworkImage(artist.imagenUrl)),
                                title: Text(artist.nombreArtistico, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(artist.paisOrigen, style: const TextStyle(color: AppColors.greyText)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                      onPressed: () => _showArtistDialog(artist: artist),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                      onPressed: () async {
                                        await artistProvider.eliminarArtista(artist.artistaId);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- SONGS TAB ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Listado de Canciones", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () => _showSongDialog(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Nueva"),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, minimumSize: const Size(90, 36)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: musicProvider.canciones.length,
                            itemBuilder: (context, index) {
                              final song = musicProvider.canciones[index];
                              return ListTile(
                                leading: Image.network(song.imagenUrl, width: 40, height: 40, fit: BoxFit.cover),
                                title: Text(song.titulo, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text("${song.artista} • ${song.album}", style: const TextStyle(color: AppColors.greyText)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                      onPressed: () => _showSongDialog(song: song),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                      onPressed: () async {
                                        await musicProvider.eliminarCancion(song.cancionId);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- PLAYLISTS TAB ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Listado de Playlists", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () => _showPlaylistDialog(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Nueva"),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, minimumSize: const Size(90, 36)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: playlistProvider.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                              : ListView.builder(
                                  itemCount: playlistProvider.allPlaylists.length,
                                  itemBuilder: (context, index) {
                                    final pl = playlistProvider.allPlaylists[index];
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: AppColors.primaryPink,
                                        child: Icon(Icons.playlist_play, color: AppColors.white),
                                      ),
                                      title: Text(pl.nombre, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                      subtitle: Text("${pl.descripcion} • ${pl.cancionesIds.length} canciones", style: const TextStyle(color: AppColors.greyText)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                            onPressed: () => _showPlaylistDialog(playlist: pl),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                            onPressed: () async {
                                              await playlistProvider.eliminarPlaylistAdmin(pl.playlistId);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // --- USERS TAB ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Listado de Usuarios", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: AppColors.primaryPink),
                              onPressed: _loadUsuarios,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _isLoadingUsuarios
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                              : ListView.builder(
                                  itemCount: _usuarios.length,
                                  itemBuilder: (context, index) {
                                    final usr = _usuarios[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: usr.foto.isNotEmpty ? NetworkImage(usr.foto) : null,
                                        child: usr.foto.isEmpty ? const Icon(Icons.person) : null,
                                      ),
                                      title: Text(usr.nombre, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                      subtitle: Text("${usr.email} • Rol: ${usr.rol.toUpperCase()}", style: const TextStyle(color: AppColors.greyText)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              usr.rol == 'admin' ? Icons.admin_panel_settings : Icons.person_outline,
                                              color: usr.rol == 'admin' ? AppColors.primaryPink : Colors.blueAccent,
                                              size: 20,
                                            ),
                                            tooltip: usr.rol == 'admin' ? "Quitar Admin" : "Hacer Admin",
                                            onPressed: () => _toggleUserRole(usr),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                            tooltip: "Eliminar Usuario",
                                            onPressed: () => _deleteUser(usr),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: AppColors.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: AppColors.greyText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
