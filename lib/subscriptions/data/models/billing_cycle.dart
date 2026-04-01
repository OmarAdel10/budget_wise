import 'package:budget_wise/l10n/app_localizations.dart';

enum BillingCycle { weekly, monthly, quarterly, halfYearly, yearly }

extension BillingCycleExtension on BillingCycle {
  String label(AppLocalizations l10n) {
    switch (this) {
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
