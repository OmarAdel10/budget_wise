import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/category/view/widgets/category_header_card.dart';

class CategoryDetailHeader extends StatelessWidget {
  final String categoryId;

  const CategoryDetailHeader({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return context.select((HomeBloc bloc) {
      final categoryIndex = bloc.state.model.categories.indexWhere(
        (cat) => cat.source.financialId == categoryId,
      );

      if (categoryIndex == -1) return const SizedBox.shrink();

      final categoryData = bloc.state.model.categories[categoryIndex];
      final category = categoryData.source as CategoryModel;
      final budget = category.budgetAmount ?? 0;
      final spending = categoryData.amount;

      double? progress;
      if (category.hasBudgetAmount && budget > 0) {
        progress = spending / budget;
      }

      return RepaintBoundary(
        child: CategoryHeaderCard(
          title: categoryData.source.financialTitle,
          totalSpending: categoryData.amount,
          budgetAmount: category.budgetAmount,
          hasBudgetAmount: category.hasBudgetAmount,
          icon: categoryData.source.financialIcon,
          color: category.type == TransactionType.transfer
              ? AppColors.transfer
              : category.type == TransactionType.income
              ? AppColors.income
              : AppColors.expense,
          progress: progress,
        ),
      );
    });
  }
}
