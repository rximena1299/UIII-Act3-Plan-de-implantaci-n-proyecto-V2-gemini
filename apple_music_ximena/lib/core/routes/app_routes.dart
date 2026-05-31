import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/main_navigation.dart';
import '../../screens/reproductor/reproductor_screen.dart';
import '../../screens/admin/admin_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/splash';

      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      if (loggedIn && state.matchedLocation == '/login') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Full screen player
      GoRoute(
        path: '/reproductor',
        builder: (context, state) => const ReproductorScreen(),
      ),

      // Admin Panel
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),

      // Shell Route for Tab Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const TabPlaceholder(index: 0),
          ),
          GoRoute(
            path: '/music',
            builder: (context, state) => const TabPlaceholder(index: 1),
          ),
          GoRoute(
            path: '/playlists',
            builder: (context, state) => const TabPlaceholder(index: 2),
          ),
          GoRoute(
            path: '/artists',
            builder: (context, state) => const TabPlaceholder(index: 3),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const TabPlaceholder(index: 4),
          ),
        ],
      ),
    ],
  );
}

// Simple switcher helper for the shell children
class TabPlaceholder extends StatelessWidget {
  final int index;
  const TabPlaceholder({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return MainNavigation.getTabScreen(index);
  }
}
