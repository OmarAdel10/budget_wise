import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/utils/subscription_formatter.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = BillingUtils.isOverdue(subscription.nextBillingDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isOverdue
              ? Border.all(color: AppColors.danger, width: 2)
              : Border.all(color: AppColors.borderColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                subscription.icon,
                color: AppColors.primaryAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isOverdue
                        ? l10n.overdue
                        : l10n.nextBillingDate(
                            SubscriptionFormatter.formatDate(
                              subscription.nextBillingDate,
                            ),
                          ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isOverdue
                          ? AppColors.danger
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  SubscriptionFormatter.formatCurrency(
                    subscription.amount,
                    subscription.currency,
                  ),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                Text(
                  SubscriptionFormatter.getCycleLabel(
                    subscription.billingCycle,
                    l10n,
                  ).toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
