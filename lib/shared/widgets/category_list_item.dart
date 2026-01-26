import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';

class CategoryListItem extends StatelessWidget {
  final String name;
  final String amount;
  final String totalBudget;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int? index;
  final bool hasBudgetAmount;
  final bool isIncome;

  const CategoryListItem({
    super.key,
    required this.name,
    required this.amount,
    required this.totalBudget,
    required this.icon,
    required this.onTap,
    this.onDelete,
    this.index,
    this.progress,
    this.hasBudgetAmount = false,
    this.isIncome = false,
  });

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressPercent = progress != null
        ? (progress! * 100).clamp(0, 999).toInt()
        : 0;

    Widget content = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            if (index != null)
              ReorderableDragStartListener(
                index: index!,
                child: const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  isIncome
                      ? Text(
                          '\$$amount',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : hasBudgetAmount
                      ? Text(
                          '\$$amount / \$$totalBudget',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : Text(
                          l10n.hasNoBudget,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                ],
              ),
            ),
            // Progress bar with percentage beside chevron
            if (progress != null) ...[
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$progressPercent%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: progress! > 1.0
                            ? Colors.red
                            : AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        backgroundColor: AppColors.cardBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress! > 1.0
                              ? Colors.red
                              : AppColors.primaryAccent,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );

    if (onDelete != null) {
      return Slidable(
        key: ValueKey(name),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) => onDelete?.call(),
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
