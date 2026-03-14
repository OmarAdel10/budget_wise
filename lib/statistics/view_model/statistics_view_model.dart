import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final TransactionBloc transactionBloc;
  final CategoryBloc categoryBloc;
  final SavingsBloc savingsBloc;
  final SubscriptionBloc subscriptionBloc;

  StatisticsBloc({
    required this.transactionBloc,
    required this.categoryBloc,
    required this.savingsBloc,
    required this.subscriptionBloc,
  }) : super(
         StatisticsStateInitial(
           StatisticsModel(
             totalIncome: 0,
             totalExpenses: 0,
             totalSavings: 0,
             totalSubscriptions: 0,
             incomeBreakdown: const [],
             expenseBreakdown: const [],
             savingsBreakdown: const [],
             subscriptionBreakdown: const [],
             dailyIncomeTrend: const [],
             dailyExpenseTrend: const [],
             dailySavingsTrend: const [],
             dailySubscriptionTrend: const [],
             sortingType: StatisticsSorting.highestAmount,
             selectedMonth: DateTime.now(),
           ),
         ),
       ) {
    // Listen to changes in transactions, categories, and savings to update statistics
    transactionBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    categoryBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    savingsBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    subscriptionBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    on<StatisticsEventLoadRequested>((event, emit) {
      try {
        final allTransactions = transactionBloc.state.transactionsList;
        final allCategories = categoryBloc.state.categoriesList;
        final allSavingGoals = savingsBloc.state.savingsList;
        final allSubscriptions = subscriptionBloc.state.subscriptions;

        double income = 0;
        double expenses = 0;
        final Map<String, double> incomeMap = {};
        final Map<String, double> expenseMap = {};

        // Filter transactions by selected month
        final monthTransactions = allTransactions.where((trans) {
          return trans.transactionDate.year == event.selectedMonth.year &&
              trans.transactionDate.month == event.selectedMonth.month;
        }).toList();

        // Calculate daily trends
        final daysInMonth = DateTime(
          event.selectedMonth.year,
          event.selectedMonth.month + 1,
          0,
        ).day;
        final List<double> dailyIncomeTrend = List.filled(daysInMonth, 0.0);
        final List<double> dailyExpenseTrend = List.filled(daysInMonth, 0.0);
        final List<double> dailySavingsTrend = List.filled(daysInMonth, 0.0);
        final List<double> dailySubscriptionTrend = List.filled(
          daysInMonth,
          0.0,
        );

        for (var transaction in monthTransactions) {
          final day = transaction.transactionDate.day - 1;
          if (transaction.type == TransactionType.income) {
            income += transaction.transactionAmount;
            incomeMap[transaction.categoryId] =
                (incomeMap[transaction.categoryId] ?? 0.0) +
                transaction.transactionAmount;
            dailyIncomeTrend[day] += transaction.transactionAmount;
          } else {
            expenses += transaction.transactionAmount;
            expenseMap[transaction.categoryId] =
                (expenseMap[transaction.categoryId] ?? 0.0) +
                transaction.transactionAmount;
            dailyExpenseTrend[day] += transaction.transactionAmount;
          }
        }

        // Map income categories with their amounts
        final incomeBreakdown = allCategories
            .where((cat) => cat.type == TransactionType.income)
            .map((cat) {
              final amount = incomeMap[cat.id] ?? 0.0;
              final percentage = income > 0 ? (amount / income) * 100 : 0.0;
              return FinancialBreakdownItem(
                source: cat,
                sourceType: StatisticsSourceType.category,
                amount: amount,
                percentage: percentage,
              );
            })
            .where((element) => element.amount > 0)
            .toList();

        // Map expense categories with their spending
        final expenseBreakdown = allCategories
            .where((cat) => cat.type == TransactionType.expense)
            .map((cat) {
              final amount = expenseMap[cat.id] ?? 0.0;
              final percentage = expenses > 0 ? (amount / expenses) * 100 : 0.0;
              return FinancialBreakdownItem(
                source: cat,
                sourceType: StatisticsSourceType.category,
                amount: amount,
                percentage: percentage,
              );
            })
            .where((element) => element.amount > 0)
            .toList();

        // Calculate savings for the selected month
        double totalSavings = 0;
        final List<FinancialBreakdownItem> savingsBreakdown = [];

        for (var goal in allSavingGoals) {
          double goalMonthlySaving = 0;
          // Calculate how much was saved for this goal in the selected month
          goal.contributionDates.forEach((dayIndex, date) {
            if (date.year == event.selectedMonth.year &&
                date.month == event.selectedMonth.month) {
              final amount = goal.getAmountForDay(dayIndex);
              goalMonthlySaving += amount;
              dailySavingsTrend[date.day - 1] += amount;
            }
          });

          if (goalMonthlySaving > 0) {
            totalSavings += goalMonthlySaving;

            savingsBreakdown.add(
              FinancialBreakdownItem(
                source: goal,
                sourceType: StatisticsSourceType.savings,
                amount: goalMonthlySaving,
                percentage: 0.0,
              ),
            );
          }
        }

        // Calculate percentages for savings breakdown
        for (var i = 0; i < savingsBreakdown.length; i++) {
          final item = savingsBreakdown[i];
          final percentage = totalSavings > 0
              ? (item.amount / totalSavings) * 100
              : 0.0;
          savingsBreakdown[i] = item.copyWith(percentage: percentage);
        }

        // Calculate subscriptions for the selected month
        double totalSubscriptions = 0;
        final List<FinancialBreakdownItem> subscriptionBreakdown = [];

        for (var sub in allSubscriptions) {
          if (sub.inActive) continue;

          // Simple approach: show the monthly equivalent cost for all active subscriptions
          double monthlyAmount = 0;
          switch (sub.billingCycle) {
            case BillingCycle.weekly:
              monthlyAmount = sub.amount * 52 / 12;

              // Calculate daily trend for weekly subscriptions
              DateTime current = sub.startDate;
              DateTime targetMonthStart = DateTime(
                event.selectedMonth.year,
                event.selectedMonth.month,
                1,
              );
              int daysDiff = targetMonthStart.difference(current).inDays;
              if (daysDiff > 0) {
                int occurrencesToSkip = (daysDiff / 7).ceil();
                current = current.add(Duration(days: occurrencesToSkip * 7));
              }
              while (current.year == event.selectedMonth.year &&
                  current.month == event.selectedMonth.month) {
                dailySubscriptionTrend[current.day - 1] += sub.amount;
                current = current.add(const Duration(days: 7));
              }
              break;
            case BillingCycle.monthly:
              monthlyAmount = sub.amount;
              if (sub.billingDay <= daysInMonth) {
                dailySubscriptionTrend[sub.billingDay - 1] += sub.amount;
              }
              break;
            case BillingCycle.quarterly:
              monthlyAmount = sub.amount / 3;
              _addOccasionalSubToTrend(
                sub,
                event.selectedMonth,
                dailySubscriptionTrend,
              );
              break;
            case BillingCycle.halfYearly:
              monthlyAmount = sub.amount / 6;
              _addOccasionalSubToTrend(
                sub,
                event.selectedMonth,
                dailySubscriptionTrend,
              );
              break;
            case BillingCycle.yearly:
              monthlyAmount = sub.amount / 12;
              _addOccasionalSubToTrend(
                sub,
                event.selectedMonth,
                dailySubscriptionTrend,
              );
              break;
          }

          totalSubscriptions += monthlyAmount;
          subscriptionBreakdown.add(
            FinancialBreakdownItem(
              source: sub,
              sourceType: StatisticsSourceType.subscription,
              amount: monthlyAmount,
              percentage: 0.0,
            ),
          );
        }

        // Calculate percentages for subscription breakdown
        for (var i = 0; i < subscriptionBreakdown.length; i++) {
          final item = subscriptionBreakdown[i];
          final percentage = totalSubscriptions > 0
              ? (item.amount / totalSubscriptions) * 100
              : 0.0;
          subscriptionBreakdown[i] = item.copyWith(percentage: percentage);
        }

        // Sort breakdowns based on current sorting type
        _applySorting(incomeBreakdown, state.model.sortingType);
        _applySorting(expenseBreakdown, state.model.sortingType);
        _applySorting(savingsBreakdown, state.model.sortingType);
        _applySorting(subscriptionBreakdown, state.model.sortingType);

        final updatedModel = state.model.copyWith(
          totalIncome: income,
          totalExpenses: expenses,
          totalSavings: totalSavings,
          totalSubscriptions: totalSubscriptions,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
          savingsBreakdown: savingsBreakdown,
          subscriptionBreakdown: subscriptionBreakdown,
          dailyIncomeTrend: dailyIncomeTrend,
          dailyExpenseTrend: dailyExpenseTrend,
          dailySavingsTrend: dailySavingsTrend,
          dailySubscriptionTrend: dailySubscriptionTrend,
          selectedMonth: event.selectedMonth,
        );

        emit(StatisticsStateSuccess(updatedModel));
      } catch (e) {
        emit(StatisticsStateError(state.model, e.toString()));
      }
    });

    on<StatisticsEventSortChanged>((event, emit) {
      final incomeBreakdown = List<FinancialBreakdownItem>.from(
        state.model.incomeBreakdown,
      );
      final expenseBreakdown = List<FinancialBreakdownItem>.from(
        state.model.expenseBreakdown,
      );
      final savingsBreakdown = List<FinancialBreakdownItem>.from(
        state.model.savingsBreakdown,
      );
      final subscriptionBreakdown = List<FinancialBreakdownItem>.from(
        state.model.subscriptionBreakdown,
      );

      _applySorting(incomeBreakdown, event.sortingType);
      _applySorting(expenseBreakdown, event.sortingType);
      _applySorting(savingsBreakdown, event.sortingType);
      _applySorting(subscriptionBreakdown, event.sortingType);

      final updatedModel = state.model.copyWith(
        sortingType: event.sortingType,
        incomeBreakdown: incomeBreakdown,
        expenseBreakdown: expenseBreakdown,
        savingsBreakdown: savingsBreakdown,
        subscriptionBreakdown: subscriptionBreakdown,
      );

      emit(StatisticsStateSuccess(updatedModel));
    });

    on<StatisticsEventToggleType>((event, emit) {
      final updatedModel = state.model.copyWith(toggleType: event.toggleType);
      emit(StatisticsStateSuccess(updatedModel));
    });
  }

  void _addOccasionalSubToTrend(
    SubscriptionModel sub,
    DateTime selectedMonth,
    List<double> dailySubscriptionTrend,
  ) {
    if (sub.nextBillingDate.year == selectedMonth.year &&
        sub.nextBillingDate.month == selectedMonth.month) {
      dailySubscriptionTrend[sub.nextBillingDate.day - 1] += sub.amount;
    } else if (sub.lastPaidDate != null &&
        sub.lastPaidDate!.year == selectedMonth.year &&
        sub.lastPaidDate!.month == selectedMonth.month) {
      dailySubscriptionTrend[sub.lastPaidDate!.day - 1] += sub.amount;
    }
  }

  void _applySorting(
    List<FinancialBreakdownItem> breakdown,
    StatisticsSorting type,
  ) {
    switch (type) {
      case StatisticsSorting.highestAmount:
        breakdown.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case StatisticsSorting.lowestAmount:
        breakdown.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case StatisticsSorting.alphabetical:
        breakdown.sort(
          (a, b) => a.source.financialTitle.compareTo(b.source.financialTitle),
        );
        break;
    }
  }
}
