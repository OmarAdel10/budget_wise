import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:intl/intl.dart';

class SubscriptionFormatter {
  static final Map<String, NumberFormat> _currencyCache = {};
  static final Map<String, DateFormat> _dateCache = {};

  static NumberFormat _getCurrencyFormat(String symbol) {
    return _currencyCache.putIfAbsent(
      symbol,
      () => NumberFormat.simpleCurrency(name: symbol),
    );
  }

  static DateFormat _getDateFormat(String pattern) {
    return _dateCache.putIfAbsent(pattern, () => DateFormat(pattern));
  }

  static String formatCurrency(double amount, String symbol) {
    return _getCurrencyFormat(symbol).currencyName! + '${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date, {String pattern = 'MMM dd'}) {
    return _getDateFormat(pattern).format(date);
  }

  static String getCycleLabel(BillingCycle cycle, AppLocalizations l10n) {
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
