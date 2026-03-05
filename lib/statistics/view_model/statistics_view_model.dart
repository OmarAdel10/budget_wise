import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final TransactionBloc transactionBloc;
  final CategoryBloc categoryBloc;

  StatisticsBloc({required this.transactionBloc, required this.categoryBloc})
    : super(
        StatisticsStateInitial(
          StatisticsModel(
            totalIncome: 0,
            totalExpenses: 0,
            totalSavings: 0,
            totalSubscriptions: 0,
            incomeBreakdown: const [],
            expenseBreakdown: const [],
            dailyIncomeTrend: const [],
            dailyExpenseTrend: const [],
            sortingType: StatisticsSorting.highestAmount,
            selectedMonth: DateTime.now(),
          ),
        ),
      ) {
    // Listen to changes in transactions and categories to update statistics
    transactionBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    categoryBloc.stream.listen((_) {
      add(StatisticsEventLoadRequested(state.model.selectedMonth));
    });

    on<StatisticsEventLoadRequested>((event, emit) {
      try {
        final allTransactions = transactionBloc.state.transactionsList;
        final allCategories = categoryBloc.state.categoriesList;

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
              return CategoriesWithSpending(
                cat,
                amount,
                percentage: percentage,
              );
            })
            .where((element) => element.totalSpending > 0)
            .toList();

        // Map expense categories with their spending
        final expenseBreakdown = allCategories
            .where((cat) => cat.type == TransactionType.expense)
            .map((cat) {
              final amount = expenseMap[cat.id] ?? 0.0;
              final percentage = expenses > 0 ? (amount / expenses) * 100 : 0.0;
              return CategoriesWithSpending(
                cat,
                amount,
                percentage: percentage,
              );
            })
            .where((element) => element.totalSpending > 0)
            .toList();

        // Sort based on current sorting type
        _applySorting(incomeBreakdown, state.model.sortingType);
        _applySorting(expenseBreakdown, state.model.sortingType);

        final updatedModel = state.model.copyWith(
          totalIncome: income,
          totalExpenses: expenses,
          totalSavings: 0.0,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
          dailyIncomeTrend: dailyIncomeTrend,
          dailyExpenseTrend: dailyExpenseTrend,
          selectedMonth: event.selectedMonth,
        );

        emit(StatisticsStateSuccess(updatedModel));
      } catch (e) {
        emit(StatisticsStateError(state.model, e.toString()));
      }
    });

    on<StatisticsEventSortChanged>((event, emit) {
      final incomeBreakdown = List<CategoriesWithSpending>.from(
        state.model.incomeBreakdown,
      );
      final expenseBreakdown = List<CategoriesWithSpending>.from(
        state.model.expenseBreakdown,
      );

      _applySorting(incomeBreakdown, event.sortingType);
      _applySorting(expenseBreakdown, event.sortingType);

      final updatedModel = state.model.copyWith(
        sortingType: event.sortingType,
        incomeBreakdown: incomeBreakdown,
        expenseBreakdown: expenseBreakdown,
      );

      emit(StatisticsStateSuccess(updatedModel));
    });

    on<StatisticsEventToggleType>((event, emit) {
      final updatedModel = state.model.copyWith(toggleType: event.toggleType);
      emit(StatisticsStateSuccess(updatedModel));
    });
  }

  void _applySorting(
    List<CategoriesWithSpending> breakdown,
    StatisticsSorting type,
  ) {
    switch (type) {
      case StatisticsSorting.highestAmount:
        breakdown.sort((a, b) => b.totalSpending.compareTo(a.totalSpending));
        break;
      case StatisticsSorting.lowestAmount:
        breakdown.sort((a, b) => a.totalSpending.compareTo(b.totalSpending));
        break;
      case StatisticsSorting.alphabetical:
        breakdown.sort(
          (a, b) =>
              a.category.categoryTitle.compareTo(b.category.categoryTitle),
        );
        break;
    }
  }
}
