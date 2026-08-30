import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class AddTransactionSaveService {
  final TransactionBloc transactionBloc;
  final AccountBloc accountBloc;
  final CategoryBloc categoryBloc;
  final SettingsBloc settingsBloc;

  const AddTransactionSaveService({
    required this.transactionBloc,
    required this.accountBloc,
    required this.categoryBloc,
    required this.settingsBloc,
  });

  void saveNormal({
    required TransactionType type,
    required double amount,
    required double convertedAmount,
    required String currency,
    required String? categoryId,
    required String accountId,
    required String? toAccountId,
    required DateTime date,
    required String? notes,
    required String? description,
    required String defaultCurrencySymbol,
    TransactionModel? existing,
    VoidCallback? onCreateBudgetExceeded,
    VoidCallback? onUpdateBudgetExceeded,
  }) {
    if (existing != null) {
      final updatedTransaction = existing.copyWith(
        type: type,
        description: description?.isEmpty == true ? null : description,
        transactionAmount: amount,
        transactionCurrency: currency,
        categoryId: categoryId,
        accountId: accountId,
        toAccountId: toAccountId,
        transactionDate: date,
        transactionNotes: notes,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      transactionBloc.add(
        TransactionEventUpdateTransaction(
          updatedTransaction,
          convertedAmount: convertedAmount,
          toastCallback: onUpdateBudgetExceeded ?? () {},
        ),
      );
    } else {
      final newTransaction = TransactionModel(
        id: const Uuid().v4(),
        userId: '',
        type: type,
        description: description?.isEmpty == true ? null : description,
        transactionAmount: amount,
        transactionCurrency: currency,
        categoryId: categoryId ?? SystemCategoryIds.accountTransfer,
        accountId: accountId,
        toAccountId: toAccountId,
        transactionDate: date,
        transactionNotes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      transactionBloc.add(
        TransactionEventCreateTransaction(
          newTransaction,
          convertedAmount: convertedAmount,
          toastCallback: onCreateBudgetExceeded ?? () {},
        ),
      );
    }
  }

  void saveTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String fromCurrency,
    required double destinationAmount,
    required String destinationCurrency,
    required DateTime date,
    required String? notes,
    required String fromDescription,
    required String toDescription,
    String? categoryId,
    VoidCallback? onBudgetExceeded,
  }) {
    transactionBloc.add(
      TransactionEventCreateTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        fromCurrency: fromCurrency,
        destinationAmount: destinationAmount,
        destinationCurrency: destinationCurrency,
        transactionDate: date,
        transactionNotes: notes,
        fromDescription: fromDescription,
        toDescription: toDescription,
        categoryId: categoryId,
        toastCallback: onBudgetExceeded ?? () {},
      ),
    );
  }

  void updateTransfer({
    required TransactionModel existing,
    required double amount,
    required DateTime date,
    required String? notes,
  }) {
    final updatedTransaction = existing.copyWith(
      transactionAmount: amount,
      transactionDate: date,
      transactionNotes: notes,
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    transactionBloc.add(
      TransactionEventUpdateTransaction(
        updatedTransaction,
        convertedAmount: amount,
        toastCallback: () {},
      ),
    );

    if (existing.transferGroupId != null) {
      final allTrans = transactionBloc.state.transactionsList;
      final paired = allTrans.where(
        (t) =>
            t.transferGroupId == existing.transferGroupId &&
            t.id != existing.id,
      );
      for (final leg in paired) {
        transactionBloc.add(
          TransactionEventUpdateTransaction(
            leg.copyWith(
              transactionAmount: amount,
              transactionDate: date,
              transactionNotes: notes,
              isSynced: false,
              updatedAt: DateTime.now(),
            ),
            convertedAmount: amount,
            toastCallback: () {},
          ),
        );
      }
    }
  }

  void deleteTransaction(String transactionId) {
    transactionBloc.add(
      TransactionEventDeleteTransaction(transactionId: transactionId),
    );
  }

  bool isBudgetExceeded({
    required String? categoryId,
    required double amount,
    required TransactionType type,
    required DateTime month,
    String? excludeTransactionId,
  }) {
    if (type != TransactionType.expense || categoryId == null) return false;
    final category = categoryBloc.state.categoriesList
        .where((c) => c.id == categoryId)
        .firstOrNull;
    if (category == null || !category.hasBudgetAmount) return false;
    final currentSpending = transactionBloc.state.getCategorySpending(
      categoryId: category.id,
      month: month.month,
      year: month.year,
      excludeTransactionId: excludeTransactionId,
    );
    return currentSpending + amount > (category.budgetAmount ?? 0);
  }
}
