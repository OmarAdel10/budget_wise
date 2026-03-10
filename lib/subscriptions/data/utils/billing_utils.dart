import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';

class BillingUtils {
  /// Calculates the next billing date based on the [lastBillingDate],
  /// the [billingDay] (1-31) they signed up on, and the [cycle].
  ///
  /// Implements "snap-back" logic: if signed up on the 31st, it will trigger
  /// on the last day of the month for shorter months, and "snap back" to the
  /// 31st for longer months.
  static DateTime calculateNextBillingDate({
    required DateTime lastBillingDate,
    required int billingDay,
    required BillingCycle cycle,
  }) {
    switch (cycle) {
      case BillingCycle.weekly:
        return lastBillingDate.add(const Duration(days: 7));
      case BillingCycle.monthly:
        return _addMonths(lastBillingDate, 1, billingDay);
      case BillingCycle.quarterly:
        return _addMonths(lastBillingDate, 3, billingDay);
      case BillingCycle.halfYearly:
        return _addMonths(lastBillingDate, 6, billingDay);
      case BillingCycle.yearly:
        return _addMonths(lastBillingDate, 12, billingDay);
    }
  }

  static DateTime _addMonths(DateTime from, int monthsToAdd, int originalDay) {
    int year = from.year;
    int month = from.month + monthsToAdd;

    // Adjust year if month overflows 12
    while (month > 12) {
      month -= 12;
      year++;
    }

    // Find the last day of the target month
    int lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;

    // Snap to the last day if originalDay doesn't exist in target month
    int day = originalDay > lastDayOfTargetMonth ? lastDayOfTargetMonth : originalDay;

    return DateTime(year, month, day, from.hour, from.minute, from.second);
  }

  /// Checks if a subscription is overdue.
  static bool isOverdue(DateTime nextBillingDate) {
    final now = DateTime.now();
    return now.isAfter(nextBillingDate);
  }

  /// Returns the number of days until the next billing date.
  static int daysUntil(DateTime nextBillingDate) {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}
