import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Input
          CustomTextField(
            hintText: l10n.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.emailRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Input
          CustomTextField(
            hintText: l10n.password,
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.passwordRequired;
              }

              if (value.length < 6) {
                return l10n.passwordTooShort;
              }
              return null;
            },
          ),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: 0,
                ),
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(
                l10n.forgotPassword,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
