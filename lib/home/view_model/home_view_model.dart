import 'dart:async';

import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/category/data/repositories/category_repository.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final SettingsBloc settingsBloc;
  final CategoryBloc categoryBloc;
  final TransactionBloc transactionBloc;
  late final StreamSubscription _transSub;
  late final StreamSubscription _catSub;

  HomeBloc({
    required this.categoryRepository,
    required this.transactionRepository,
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
    if (settingsBloc.state.model.hasLoggedIn) {
      transactionBloc.add(const TransactionEventSyncUnsynced());
      categoryBloc.add(const CategoryEventSyncUnsynced());
    }
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
  }) {
    try {
      final currentMonth = monthDate ?? state.model.currentMonth;
      final currentAccountId = accountId ?? state.model.filterAccountId;

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

      emit(
        HomeStateSuccess(
          model: state.model.copyWith(
            categories: categoriesWithSpendingList,
            currentMonth: currentMonth,
            filterAccountId: currentAccountId,
            totalIncome: income,
            totalExpenses: expenses,
            transactions: filteredTransactions,
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

  // on<HomeEventLoadAllData>((event, emit) async {
  //   emit(HomeStateLoading());
  //   try {
  //     final categoriesSnapShot = await categoryRepository
  //         .getCategoriesCollection()
  //         .where('userId', isEqualTo: authRepository.currentUser!.uid)
  //         .get();
  //     final transactions = await transactionRepository.getTransactionsByMonth(
  //       event.monthDate,
  //     );
  //     double totalIncome = 0;
  //     double totalOutcome = 0;
  //     Map<String, dynamic> categoriesWithSpendingMap = {};

  //     for (var transaction in transactions) {
  //       if (transaction.type == TransactionType.income) {
  //         totalIncome += transaction.transactionAmount;
  //       } else {
  //         totalOutcome += transaction.transactionAmount;
  //       }
  //       if (categoriesWithSpendingMap.containsKey(transaction.categoryId)) {
  //         categoriesWithSpendingMap[transaction.categoryId] +=
  //             transaction.transactionAmount;
  //       } else {
  //         categoriesWithSpendingMap[transaction.categoryId] =
  //             transaction.transactionAmount;
  //       }
  //     }

  //     final List<CategoriesWithSpending> categoriesWithSpendingList =
  //         categoriesSnapShot.docs
  //             .map((doc) => doc.data())
  //             .map(
  //               (category) => CategoriesWithSpending(
  //                 category,
  //                 categoriesWithSpendingMap[category.id] ?? 0,
  //               ),
  //             )
  //             .toList();

  //     emit(
  //       HomeStateSuccess(
  //         totalIncome: totalIncome,
  //         totalOutcome: totalOutcome,
  //         currentMonth: event.monthDate,
  //         categories: categoriesWithSpendingList,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(HomeStateError(e.toString()));
  //   }
  // });
}
