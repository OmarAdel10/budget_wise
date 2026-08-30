import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_styles.dart';
import '../screens/login_screen.dart';

class SignUpFooter extends StatelessWidget {
  final bool isFromOnboarding;

  const SignUpFooter({super.key, required this.isFromOnboarding});

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.alreadyHaveAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            if (isFromOnboarding) {
              Navigator.of(context).pop('switch_to_login');
            } else {
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            }
          },
          child: Text(
            context.l10n.login,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
