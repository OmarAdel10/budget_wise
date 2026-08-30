import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SmsDraftActionButtons extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback onDecline;
  final VoidCallback? onEdit;
  final bool isWarningShown;

  const SmsDraftActionButtons({
    super.key,
    required this.onConfirm,
    required this.onDecline,
    this.onEdit,
    this.isWarningShown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: AppColors.danger.withValues(alpha: .1),
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: .4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                icon: const Icon(PhosphorIconsBold.trash, size: 18),
                label: Text(
                  context.l10n.decline,
                  style: AppTextStyles.button.copyWith(color: AppColors.danger),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                icon: Icon(
                  isWarningShown
                      ? PhosphorIconsBold.warningCircle
                      : PhosphorIconsBold.checkCircle,
                  size: 18,
                  color: AppColors.textInverse,
                ),
                label: Text(
                  isWarningShown
                      ? context.l10n.confirmAnyway
                      : context.l10n.confirm,
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
        if (onEdit != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    backgroundColor: AppColors.textSecondary.withValues(
                      alpha: .1,
                    ),
                    side: BorderSide(
                      color: AppColors.textSecondary.withValues(alpha: .4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  icon: const Icon(PhosphorIconsBold.pencilSimple, size: 18),
                  label: Text(
                    context.l10n.editDraft,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
