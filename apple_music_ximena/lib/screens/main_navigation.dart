import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import '../providers/artista_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/mini_player.dart';

// Import screens
import 'home/home_screen.dart';
import 'musica/musica_screen.dart';
import 'playlists/playlists_screen.dart';
import 'artistas/artistas_screen.dart';
import 'perfil/perfil_screen.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  // Switch tab screens
  static Widget getTabScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const MusicaScreen();
      case 2:
        return const PlaylistsScreen();
      case 3:
        return const ArtistasScreen();
      case 4:
        return const PerfilScreen();
      default:
        return const HomeScreen();
    }
  }
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MusicProvider>(context, listen: false).fetchSongs();
      Provider.of<ArtistaProvider>(context, listen: false).fetchArtistas();
    });
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/music')) return 1;
    if (location.startsWith('/playlists')) return 2;
    if (location.startsWith('/artists')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/music');
        break;
      case 2:
        context.go('/playlists');
        break;
      case 3:
        context.go('/artists');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _getSelectedIndex(context);
    final bool isWideScreen = MediaQuery.of(context).size.width >= 700;
    final authProvider = Provider.of<AuthProvider>(context);

    Widget bottomBar = BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(index, context),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.music_note_outlined),
          activeIcon: Icon(Icons.music_note),
          label: AppStrings.music,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music),
          label: AppStrings.playlists,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt),
          label: AppStrings.artists,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );

    if (isWideScreen) {
      return Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                // Custom Sidebar instead of bottom bar
                Container(
                  width: 240,
                  color: AppColors.secondaryBackground,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // App logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.music_note, color: AppColors.primaryPink, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            "Apple Music",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Sidebar Navigation Items
                      _buildSidebarItem(context, 0, Icons.home, AppStrings.home, selectedIndex),
                      _buildSidebarItem(context, 1, Icons.music_note, AppStrings.music, selectedIndex),
                      _buildSidebarItem(context, 2, Icons.library_music, AppStrings.playlists, selectedIndex),
                      _buildSidebarItem(context, 3, Icons.people, AppStrings.artists, selectedIndex),
                      _buildSidebarItem(context, 4, Icons.person, AppStrings.profile, selectedIndex),
                      
                      const Spacer(),
                      // Admin panel access for admins
                      if (authProvider.isAdmin)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/admin'),
                            icon: const Icon(Icons.admin_panel_settings, color: AppColors.primaryPink),
                            label: const Text("Panel Admin", style: TextStyle(color: AppColors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryPink),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 80), // spacer for mini player
                    ],
                  ),
                ),
                // Main screen area
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
            // Floating MiniPlayer
            const Positioned(
              bottom: 12,
              left: 250,
              right: 12,
              child: MiniPlayer(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          // Floating MiniPlayer above BottomNavigationBar
          const Positioned(
            bottom: 56, // Height above bottom navigation bar
            left: 0,
            right: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar,
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, int index, IconData icon, String title, int selectedIndex) {
    final bool isSelected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryPink : AppColors.greyText,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.greyText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => _onItemTapped(index, context),
      ),
    );
  }
}
