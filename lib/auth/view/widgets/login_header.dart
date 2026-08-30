import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.welcomeBack,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
