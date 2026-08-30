import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onSignUp;

  const LoginFooter({
    super.key,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Login Button with isolated rebuilds
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) =>
              previous is AuthStateLoading || current is AuthStateLoading,
          builder: (context, state) {
            return RepaintBoundary(
              child: CustomButton(
                text: context.l10n.login,
                isLoading: state is AuthStateLoading,
                onPressed: onLogin,
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Google Login Button
        RepaintBoundary(
          child: CustomButton(
            text: context.l10n.loginWithGoogle,
            type: CustomButtonType.secondary,
            onPressed: onGoogleLogin,
            leftIcon: Icon(PhosphorIconsBold.googleLogo),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Sign Up Link (Footer)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.dontHaveAccount,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: onSignUp,
              child: Text(
                context.l10n.signUp,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
