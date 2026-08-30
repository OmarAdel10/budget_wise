import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

enum BillingCycle { weekly, monthly, quarterly, halfYearly, yearly }

extension BillingCycleExtension on BillingCycle {
  String label(BuildContext context) {
    switch (this) {
      case BillingCycle.weekly:
        return context.l10n.weekly;
      case BillingCycle.monthly:
        return context.l10n.monthly;
      case BillingCycle.quarterly:
        return context.l10n.quarterly;
      case BillingCycle.halfYearly:
        return context.l10n.halfYearly;
      case BillingCycle.yearly:
        return context.l10n.yearly;
    }
  }
}
