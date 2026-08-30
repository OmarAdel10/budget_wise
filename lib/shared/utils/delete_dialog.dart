import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback? onDelete;
  final String deletingType;
  const DeleteDialog({
    super.key,
    this.onDelete,
    required this.deletingType,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        minWidth: MediaQuery.sizeOf(context).width * 0.8,
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.deleteType(deletingType),
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.deleteTypeDesc(deletingType),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      elevation: 30,
      backgroundColor: AppColors.primaryBackground,
      alignment: Alignment.center,
      content: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: AppColors.borderColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.cancel,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.borderColor),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete?.call();
                  },
                  child: Text(
                    context.l10n.delete,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
