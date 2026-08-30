import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

abstract final class SystemCategorySeed {
  static List<CategoryModel> categories(String userId, DateTime now) => [
    CategoryModel(
      id: SystemCategoryIds.balanceAdjustment,
      userId: userId,
      categoryTitle: 'Balance Adjustment',
      categoryIcon: PhosphorIconsRegular.scales,
      type: TransactionType.expense,
      isDefault: true,
      isSystem: true,
      createdAt: now,
      updatedAt: now,
    ),
    CategoryModel(
      id: SystemCategoryIds.accountTransfer,
      userId: userId,
      categoryTitle: 'Account Transfer',
      categoryIcon: PhosphorIconsRegular.arrowsLeftRight,
      type: TransactionType.expense,
      isDefault: true,
      isSystem: true,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
