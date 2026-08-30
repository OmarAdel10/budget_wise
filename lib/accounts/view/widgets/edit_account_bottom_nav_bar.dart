import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class EditAccountBottomNavBar extends StatelessWidget {
  final VoidCallback onSave;

  const EditAccountBottomNavBar({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          elevation: 8,
          shadowColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              context.l10n.saveChanges,
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
