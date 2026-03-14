import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
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
    final ValueNotifier<bool> isOverdueNotifier = ValueNotifier(
      BillingUtils.isOverdue(subscription.nextBillingDate),
    );
    final isInActive = subscription.inActive;

    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: ValueListenableBuilder<bool>(
          valueListenable: isOverdueNotifier,
          builder: (context, isOverdue, child) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: isOverdue
                    ? Border.all(color: AppColors.danger, width: 2)
                    : Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.5),
                      ),
              ),
              child: Row(
                children: [
                  GenericIconContainer(
                    icon: subscription.icon,
                    color: Color(subscription.iconColorValue),
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
                              ? l10n.dueToBillingDate(
                                  SubscriptionFormatter.formatDate(
                                    subscription.nextBillingDate,
                                  ),
                                )
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
                          color: (isInActive && isOverdue)
                              ? AppColors.danger
                              : isInActive
                              ? Colors.orange
                              : isOverdue
                              ? AppColors.danger
                              : AppColors.primaryAccent,
                        ),
                      ),
                      Text(
                        '${(isInActive && isOverdue)
                            ? l10n.inActiveAndOverdue
                            : isInActive
                            ? l10n.inActive
                            : isOverdue
                            ? l10n.overdue
                            : l10n.active} • ${SubscriptionFormatter.getCycleLabel(subscription.billingCycle, l10n).toUpperCase()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: (isInActive && isOverdue)
                              ? AppColors.danger
                              : isInActive
                              ? Colors.orange
                              : isOverdue
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
