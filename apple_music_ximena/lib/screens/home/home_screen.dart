import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/music_provider.dart';
import '../../providers/artista_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/music_card.dart';
import '../../widgets/loading_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final artistaProvider = Provider.of<ArtistaProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: musicProvider.isLoading || artistaProvider.isLoading
            ? const LoadingWidget(message: 'Cargando tu música...')
            : RefreshIndicator(
                color: AppColors.primaryPink,
                onRefresh: () async {
                  await musicProvider.fetchSongs();
                  await artistaProvider.fetchArtistas();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Escuchar ahora",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                "¡Hola, ${user?.nombre ?? 'Invitado'}!",
                                style: const TextStyle(
                                  color: AppColors.greyText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Admin icon shortcut on mobile
                          if (authProvider.isAdmin && MediaQuery.of(context).size.width < 700)
                            IconButton(
                              icon: const Icon(Icons.admin_panel_settings, color: AppColors.primaryPink, size: 28),
                              onPressed: () => context.push('/admin'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p24),

                      // Featured Song Banner (Visual Wow Factor!)
                      if (musicProvider.canciones.isNotEmpty)
                        _buildFeaturedBanner(context, musicProvider.canciones.first, musicProvider),

                      const SizedBox(height: AppSizes.p32),

                      // Section: Canciones Recomendadas
                      _buildSectionHeader(context, "Canciones Recomendadas", () {
                        context.go('/music');
                      }),
                      const SizedBox(height: AppSizes.p16),
                      musicProvider.canciones.isEmpty
                          ? const Text("No hay canciones disponibles por el momento.", style: TextStyle(color: AppColors.greyText))
                          : SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: musicProvider.canciones.length,
                                itemBuilder: (context, index) {
                                  final song = musicProvider.canciones[index];
                                  return MusicCard(
                                    title: song.titulo,
                                    subtitle: song.artista,
                                    imageUrl: song.imagenUrl,
                                    onTap: () {
                                      musicProvider.playSong(song, customQueue: musicProvider.canciones);
                                    },
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: AppSizes.p32),

                      // Section: Artistas del Momento
                      _buildSectionHeader(context, "Artistas del Momento", () {
                        context.go('/artists');
                      }),
                      const SizedBox(height: AppSizes.p16),
                      artistaProvider.artistas.isEmpty
                          ? const Text("No hay artistas registrados.", style: TextStyle(color: AppColors.greyText))
                          : SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: artistaProvider.artistas.length,
                                itemBuilder: (context, index) {
                                  final artist = artistaProvider.artistas[index];
                                  return _buildArtistCircle(context, artist);
                                },
                              ),
                            ),
                      
                      const SizedBox(height: 80), // Bottom padding for floating mini player
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, dynamic song, MusicProvider provider) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.r20),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPink.withValues(alpha: 0.85),
            AppColors.secondaryPink.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background music notes watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.music_note,
              size: 200,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "LANZAMIENTO DESTACADO",
                    style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Text(
                  song.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  song.artista,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.playSong(song, customQueue: provider.canciones);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryPink),
                  label: const Text("Escuchar Ahora", style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primaryPink,
                    minimumSize: const Size(140, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            "Ver todo",
            style: TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtistCircle(BuildContext context, dynamic artist) {
    return GestureDetector(
      onTap: () {
        context.go('/artists');
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppSizes.p16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(artist.imagenUrl),
              backgroundColor: AppColors.secondaryBackground,
            ),
            const SizedBox(height: 8),
            Text(
              artist.nombreArtistico,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
