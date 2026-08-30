import 'dart:async';

import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_extensions.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SettingsBloc settingsBloc;
  final CategoryBloc categoryBloc;
  final TransactionBloc transactionBloc;
  late final StreamSubscription _transSub;
  late final StreamSubscription _catSub;

  HomeBloc({
    required this.settingsBloc,
    required this.transactionBloc,
    required this.categoryBloc,
  }) : super(
         HomeStateInitial(
           model: HomeModel(
             totalIncome: 0,
             totalExpenses: 0,
             currentMonth: DateTime.now(),
             categories: [],
             transactions: [],
           ),
         ),
       ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (settingsBloc.state.model.hasLoggedIn) {
        transactionBloc.add(const TransactionEventSyncUnsynced());
        categoryBloc.add(const CategoryEventSyncUnsynced());
      }
    });
    on<HomeEventLoadAllData>((event, emit) async {
      _loadData(emit, monthDate: event.monthDate, accountId: event.accountId);
    });

    on<HomeEventChangeMonth>((event, emit) async {
      _loadData(emit, monthDate: event.monthDate);
    });

    on<HomeEventChangeAccountFilter>((event, emit) async {
      emit(
        HomeStateSuccess(
          model: state.model.copyWith(
            filterAccountId: event.accountId,
            clearFilteredAccountId: event.accountId == null,
          ),
        ),
      );
      _loadData(emit, accountId: event.accountId);
    });

    on<HomeEventFilterByCategory>((event, emit) async {
      emit(
        HomeStateSuccess(
          model: state.model.copyWith(
            selectedCategoryId: event.categoryId,
            clearSelectedCategoryId: event.categoryId == null,
          ),
        ),
      );
      _loadData(emit, categoryId: event.categoryId);
    });

    _transSub = transactionBloc.stream.listen(
      (event) => add(
        HomeEventLoadAllData(
          state.model.currentMonth,
          accountId: state.model.filterAccountId,
        ),
      ),
    );
    _catSub = categoryBloc.stream.listen(
      (event) => add(
        HomeEventLoadAllData(
          state.model.currentMonth,
          accountId: state.model.filterAccountId,
        ),
      ),
    );
  }

  void _loadData(
    Emitter<HomeState> emit, {
    DateTime? monthDate,
    String? accountId,
    String? categoryId,
  }) {
    try {
      final currentMonth = monthDate ?? state.model.currentMonth;
      final currentAccountId = accountId ?? state.model.filterAccountId;
      final currentCategoryId = categoryId ?? state.model.selectedCategoryId;

      final allTransactions = transactionBloc.state.transactionsList;
      final allCategories = categoryBloc.state.categoriesList;

      double income = 0;
      double expenses = 0;
      Map<String, double> spendingMap = {};

      final monthTransactions = allTransactions.where((trans) {
        return trans.transactionDate.year == currentMonth.year &&
            trans.transactionDate.month == currentMonth.month;
      }).toList();

      final filteredTransactions = currentAccountId == null
          ? monthTransactions
          : monthTransactions
                .where((t) => t.accountId == currentAccountId)
                .toList();

      for (final transaction in filteredTransactions) {
        if (transaction.isSystemTransaction || transaction.isTransferLeg) {
          continue;
        }
        if (transaction.type == TransactionType.income) {
          income += transaction.transactionAmount;
        } else {
          expenses += transaction.transactionAmount;
        }

        spendingMap[transaction.categoryId] =
            (spendingMap[transaction.categoryId] ?? 0.0) +
            transaction.transactionAmount;
      }

      final List<FinancialBreakdownItem> categoriesWithSpendingList =
          allCategories.map((cat) {
            return FinancialBreakdownItem(
              source: cat,
              sourceType: StatisticsSourceType.category,
              amount: spendingMap[cat.id] ?? 0.0,
              percentage: 0.0,
            );
          }).toList();

      final finalTransactions = currentCategoryId == null
          ? filteredTransactions
          : filteredTransactions
                .where((t) => t.categoryId == currentCategoryId)
                .toList();

      emit(
        HomeStateSuccess(
          model: state.model.copyWith(
            categories: categoriesWithSpendingList,
            currentMonth: currentMonth,
            filterAccountId: currentAccountId,
            selectedCategoryId: currentCategoryId,
            clearSelectedCategoryId: currentCategoryId == null,
            totalIncome: income,
            totalExpenses: expenses,
            transactions: finalTransactions,
          ),
        ),
      );
    } catch (e) {
      emit(HomeStateError(model: state.model, message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _transSub.cancel();
    _catSub.cancel();
    return super.close();
  }
}
