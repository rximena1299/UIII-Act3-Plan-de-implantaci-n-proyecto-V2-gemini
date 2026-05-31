import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/firebase_service.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/artista_provider.dart';
import 'providers/music_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Initialize firebase (or local fallback if firebase configuration files are not present)
  await FirebaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ArtistaProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp.router(
      title: 'Apple Music Ximena',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      theme: AppTheme.darkTheme, // Premium dark theme is default
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
