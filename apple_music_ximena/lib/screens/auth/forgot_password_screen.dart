import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.resetPassword(_emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Correo de recuperación enviado con éxito. Revisa tu bandeja de entrada."),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Error already saved in provider, it will be displayed in UI.
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
            Navigator.pop(context);
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
                      AppStrings.recoverPassword,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    const Text(
                      "Ingresa tu correo electrónico registrado y te enviaremos las instrucciones de recuperación.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.greyText, fontSize: 14),
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
                    const SizedBox(height: AppSizes.p24),

                    // Submit Button
                    CustomButton(
                      text: AppStrings.sendRecoveryEmail,
                      isLoading: authProvider.isLoading,
                      onPressed: _submit,
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
