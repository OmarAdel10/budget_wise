import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';

extension TransactionModelX on TransactionModel {
  bool get isBalanceAdjustment =>
      SystemCategoryIds.isBalanceAdjustment(categoryId);

  bool get isAccountTransfer => SystemCategoryIds.isAccountTransfer(categoryId);

  bool get isSystemTransaction => SystemCategoryIds.isSystem(categoryId);

  bool get isTransferLeg =>
      transferGroupId != null && transferGroupId!.isNotEmpty;
}
