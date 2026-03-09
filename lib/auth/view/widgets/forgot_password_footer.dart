import 'package:flutter/material.dart';
import '../../../../shared/constants/colors.dart';
import '../../../../shared/constants/text_styles.dart';

class ForgotPasswordFooter extends StatelessWidget {
  final String rememberPasswordText;
  final String loginText;
  final VoidCallback onLoginPressed;

  const ForgotPasswordFooter({
    super.key,
    required this.rememberPasswordText,
    required this.loginText,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          rememberPasswordText,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: onLoginPressed,
          child: Text(
            loginText,
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
