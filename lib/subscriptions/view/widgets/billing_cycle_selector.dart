import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/custom_toggle_button.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:flutter/material.dart';

class BillingCycleSelector extends StatelessWidget {
  final ValueNotifier<BillingCycle> billingCycleNotifier;

  const BillingCycleSelector({
    super.key,
    required this.billingCycleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ValueListenableBuilder<BillingCycle>(
        valueListenable: billingCycleNotifier,
        builder: (context, selectedCycle, _) {
          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: BillingCycle.values.map((cycle) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - (AppSpacing.lg * 2) - 12) / 2,
                height: 40,
                child: CustomToggleButton(
                  label: _getCycleLabel(cycle, l10n),
                  isSelected: selectedCycle == cycle,
                  onTap: () => billingCycleNotifier.value = cycle,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _getCycleLabel(BillingCycle cycle, AppLocalizations l10n) {
    switch (cycle) {
      case BillingCycle.weekly:
        return l10n.weekly;
      case BillingCycle.monthly:
        return l10n.monthly;
      case BillingCycle.quarterly:
        return l10n.quarterly;
      case BillingCycle.halfYearly:
        return l10n.halfYearly;
      case BillingCycle.yearly:
        return l10n.yearly;
    }
  }
}
