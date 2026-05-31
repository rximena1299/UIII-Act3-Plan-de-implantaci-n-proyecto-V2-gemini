import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  void _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Apple Music Styled Header
                    const Icon(
                      Icons.music_note,
                      size: 64,
                      color: AppColors.primaryPink,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    const Text(
                      AppStrings.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.greyText, fontSize: 16),
                    ),
                    const SizedBox(height: AppSizes.p32),

                    // Error Alert Banner
                    if (authProvider.errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                          border: Border.all(color: AppColors.error, width: 1),
                        ),
                        child: Text(
                          authProvider.errorMessage,
                          style: const TextStyle(color: AppColors.error, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                    ],

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (!value.contains('@')) {
                          return AppStrings.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    
                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          authProvider.clearError();
                          context.push('/forgot-password');
                        },
                        child: const Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(color: AppColors.primaryPink, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Submit Button
                    CustomButton(
                      text: 'Iniciar Sesión',
                      isLoading: authProvider.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Google Login Button
                    OutlinedButton.icon(
                      onPressed: authProvider.isLoading ? null : _loginWithGoogle,
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                        height: 20,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: AppColors.white),
                      ),
                      label: const Text(
                        AppStrings.googleLogin,
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.glassBorder),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes una cuenta? ", style: TextStyle(color: AppColors.greyText)),
                        GestureDetector(
                          onTap: () {
                            authProvider.clearError();
                            context.push('/register');
                          },
                          child: const Text(
                            "Regístrate",
                            style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
