import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/music_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/custom_button.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final user = authProvider.currentUser;

    final String formattedDate = user != null
        ? DateFormat('dd/MM/yyyy').format(user.fechaRegistro)
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Cuenta",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p32),

              // Profile Picture
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryPink, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(
                      (user?.foto.isNotEmpty ?? false)
                          ? user!.foto
                          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                    ),
                    backgroundColor: AppColors.secondaryBackground,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Name
              Text(
                user?.nombre ?? 'Usuario',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSizes.p8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.rol == 'admin' ? AppColors.primaryPink : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.rol == 'admin' ? "ADMINISTRADOR" : "SUSCRIPTOR PREMIUM",
                  style: TextStyle(
                    color: user?.rol == 'admin' ? AppColors.white : AppColors.primaryPink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p32),

              // Details Card
              Card(
                color: AppColors.secondaryBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r16)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    children: [
                      _buildDetailRow("Fecha de Registro", formattedDate, Icons.calendar_today_outlined),
                      const Divider(color: AppColors.glassBorder),
                      _buildDetailRow("Tipo de Suscripción", "Plan Individual", Icons.card_membership_outlined),
                      const Divider(color: AppColors.glassBorder),
                      _buildDetailRow("Región", "México", Icons.public),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // Admin Panel shortcut for mobile
              if (authProvider.isAdmin && MediaQuery.of(context).size.width < 700) ...[
                CustomButton(
                  text: "Panel de Administración",
                  backgroundColor: AppColors.secondaryBackground,
                  onPressed: () {
                    context.push('/admin');
                  },
                ),
                const SizedBox(height: AppSizes.p16),
              ],

              // Log Out Button
              CustomButton(
                text: "Cerrar Sesión",
                backgroundColor: AppColors.error,
                onPressed: () async {
                  await musicProvider.stop();
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 80), // Bottom padding for mini player
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPink, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.greyText, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
