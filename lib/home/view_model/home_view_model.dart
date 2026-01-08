import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/data/repositories/category_repository.dart';
import 'package:budget_wise/home/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final SettingsBloc settingsBloc;
  final CategoryBloc categoryBloc;
  final TransactionBloc transactionBloc;
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
    if (settingsBloc.state.model.isSyncToCloudEnabled) {
      transactionBloc.add(const TransactionEventSyncUnsynced());
      categoryBloc.add(const CategoryEventSyncUnsynced());
    }
    transactionBloc.stream.listen(
      (event) => add(HomeEventLoadAllData(state.model.currentMonth)),
    );
    categoryBloc.stream.listen(
      (event) => add(HomeEventLoadAllData(state.model.currentMonth)),
    );

    on<HomeEventLoadAllData>((event, emit) async {
      try {
        final allTransactions = transactionBloc.state.transactionsList;
        final allCategories = categoryBloc.state.categoriesList;
        double income = 0;
        double expenses = 0;
        Map<String, dynamic> spendingMap = {};

        final monthTransaction = allTransactions
            .where(
              (trans) =>
                  trans.transactionDate.year == event.monthDate.year &&
                  trans.transactionDate.month == event.monthDate.month,
            )
            .toList();

        for (var transaction in monthTransaction) {
          if (transaction.type == TransactionType.income) {
            income += transaction.transactionAmount;
          } else {
            expenses += transaction.transactionAmount;
            if (spendingMap.containsKey(transaction.categoryId)) {
              spendingMap[transaction.categoryId] +=
                  transaction.transactionAmount;
            } else {
              spendingMap[transaction.categoryId] =
                  transaction.transactionAmount;
            }
          }
        }

        final List<CategoriesWithSpending> categoriesWithSpendingList =
            allCategories
                .map(
                  (cat) =>
                      CategoriesWithSpending(cat, spendingMap[cat.id] ?? 0.0),
                )
                .toList();

        emit(
          HomeStateSuccess(
            model: state.model.copyWith(
              categories: categoriesWithSpendingList,
              currentMonth: event.monthDate,
              totalIncome: income,
              totalExpenses: expenses,
              transactions: monthTransaction,
            ),
          ),
        );
      } catch (e) {
        emit(HomeStateError(model: state.model, message: e.toString()));
      }
    });

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
}
