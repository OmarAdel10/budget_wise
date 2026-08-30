import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:flutter/material.dart';
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
    return '${_getCurrencyFormat(symbol).currencyName!} ${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date, {String pattern = 'MMM dd'}) {
    return _getDateFormat(pattern).format(date);
  }

  static String getCycleLabel(BillingCycle cycle, BuildContext context) {
    switch (cycle) {
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
