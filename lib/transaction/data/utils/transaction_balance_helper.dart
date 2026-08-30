import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';

/// Applies or reverses a transaction's effect on a single account balance.
void applyTransactionBalanceDelta({
  required void Function(String accountId, double amountDelta) updateBalance,
  required TransactionModel transaction,
  required double amount,
  required bool reverse,
}) {
  if (SystemCategoryIds.isBalanceAdjustment(transaction.categoryId)) {
    return;
  }

  final sign = reverse ? -1.0 : 1.0;

  if (transaction.type == TransactionType.income) {
    if (transaction.accountId.isNotEmpty) {
      updateBalance(transaction.accountId, sign * amount);
    }
    return;
  }

  if (transaction.type == TransactionType.expense) {
    if (transaction.accountId.isNotEmpty) {
      updateBalance(transaction.accountId, sign * -amount);
    }
    return;
  }

  // Legacy single-record transfer
  if (transaction.type == TransactionType.transfer) {
    if (transaction.accountId.isNotEmpty) {
      updateBalance(transaction.accountId, sign * -amount);
    }
    if (transaction.toAccountId != null && transaction.toAccountId!.isNotEmpty) {
      updateBalance(transaction.toAccountId!, sign * amount);
    }
  }
}

/// Reverses a balance_adjustment transaction (used on delete).
void reverseBalanceAdjustment({
  required void Function(String accountId, double amountDelta) updateBalance,
  required TransactionModel transaction,
}) {
  if (!SystemCategoryIds.isBalanceAdjustment(transaction.categoryId)) return;
  if (transaction.accountId.isEmpty) return;

  final delta = transaction.type == TransactionType.income
      ? -transaction.transactionAmount
      : transaction.transactionAmount;
  updateBalance(transaction.accountId, delta);
}
