import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class IconSection extends StatelessWidget {
  final ValueNotifier<IconData> selectedIcon;
  final VoidCallback onTap;
  final Color accentColor;

  const IconSection({
    super.key,
    required this.selectedIcon,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: ValueListenableBuilder<IconData>(
              valueListenable: selectedIcon,
              builder: (context, icon, _) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor),
                  ),
                  child: Icon(icon, size: 40, color: accentColor),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            l10n.tapToChangeIcon,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
