import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/value_listenable_builders.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextBillingPreview extends StatelessWidget {
  final ValueNotifier<DateTime> startDateNotifier;
  final ValueNotifier<BillingCycle> billingCycleNotifier;

  const NextBillingPreview({
    super.key,
    required this.startDateNotifier,
    required this.billingCycleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder2<DateTime, BillingCycle>(
      first: startDateNotifier,
      second: billingCycleNotifier,
      builder: (context, startDate, billingCycle, _) {
        final nextBillingPreview = BillingUtils.calculateNextBillingDate(
          lastBillingDate: startDate,
          billingDay: startDate.day,
          cycle: billingCycle,
        );

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.primaryAccent.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.nextRenewalDate, style: AppTextStyles.bodySmall),
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(nextBillingPreview),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
