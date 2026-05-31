import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryPink),
          onPressed: () {
            authProvider.clearError();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Crear Cuenta",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    const Text(
                      "Únete a Apple Music Ximena hoy",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.greyText, fontSize: 16),
                    ),
                    const SizedBox(height: AppSizes.p24),

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

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      label: AppStrings.name,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),

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
                    const SizedBox(height: AppSizes.p16),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (value != _passwordController.text) {
                          return AppStrings.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // Register Button
                    CustomButton(
                      text: 'Registrarse',
                      isLoading: authProvider.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // Back to Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta? ", style: TextStyle(color: AppColors.greyText)),
                        GestureDetector(
                          onTap: () {
                            authProvider.clearError();
                            context.pop();
                          },
                          child: const Text(
                            "Inicia Sesión",
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
