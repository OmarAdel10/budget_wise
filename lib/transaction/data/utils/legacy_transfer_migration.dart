import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Splits legacy single-record transfers into expense + income legs.
List<TransactionModel> migrateLegacyTransfers(List<TransactionModel> list) {
  final result = <TransactionModel>[];
  var changed = false;

  for (final t in list) {
    if (t.type != TransactionType.transfer) {
      result.add(t);
      continue;
    }

    changed = true;
    final groupId = const Uuid().v4();
    final now = DateTime.now();
    final categoryId =
        SystemCategoryIds.isSystem(t.categoryId) || t.categoryId == 'transfer'
        ? SystemCategoryIds.accountTransfer
        : t.categoryId;

    result.add(
      t.copyWith(
        id: '${t.id}_out',
        type: TransactionType.expense,
        categoryId: categoryId,
        toAccountId: t.toAccountId,
        transferGroupId: groupId,
        updatedAt: now,
      ),
    );

    if (t.toAccountId != null && t.toAccountId!.isNotEmpty) {
      result.add(
        t.copyWith(
          id: '${t.id}_in',
          type: TransactionType.income,
          categoryId: categoryId,
          accountId: t.toAccountId!,
          toAccountId: null,
          transferGroupId: groupId,
          updatedAt: now,
        ),
      );
    }
  }

  return changed ? result : list;
}
