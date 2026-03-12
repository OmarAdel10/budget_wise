import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionInfoGrid extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final AppLocalizations l10n;
  final bool isOverdue;

  const SubscriptionInfoGrid({
    super.key,
    required this.subscriptionModel,
    required this.l10n,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: l10n.billingCycle,
                amount: subscriptionModel.billingCycle.label(l10n),
                icon: Icons.calendar_today_outlined,
                isCompact: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SummaryCard(
                title: l10n.nextRenewalDate,
                amount: DateFormat(
                  'MMM dd, yyyy',
                ).format(subscriptionModel.nextBillingDate),
                icon: Icons.event_repeat_outlined,
                amountColor: isOverdue ? AppColors.danger : null,
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: l10n.reminder,
                amount: subscriptionModel.reminderEnabled
                    ? l10n.daysBefore(
                        subscriptionModel.remindBeforeDays,
                      )
                    : l10n.off,
                icon: Icons.notifications_active_outlined,
                isCompact: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SummaryCard(
                title: l10n.status,
                amount: subscriptionModel.isPaused
                    ? l10n.paused
                    : l10n.active,
                icon: subscriptionModel.isPaused
                    ? Icons.pause_circle_outline
                    : Icons.check_circle_outline,
                amountColor: subscriptionModel.isPaused
                    ? Colors.orange
                    : AppColors.primaryAccent,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
