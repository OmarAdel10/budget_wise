import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/category/view/widgets/category_header_card.dart';

class CategoryDetailHeader extends StatelessWidget {
  final String categoryId;

  const CategoryDetailHeader({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return context.select((HomeBloc bloc) {
      final categoryIndex = bloc.state.model.categories.indexWhere(
        (cat) => cat.category.id == categoryId,
      );

      if (categoryIndex == -1) return const SizedBox.shrink();

      final category = bloc.state.model.categories[categoryIndex];
      final budget = category.category.budgetAmount ?? 0;
      final spending = category.totalSpending;

      double? progress;
      if (category.category.hasBudgetAmount && budget > 0) {
        progress = spending / budget;
      }

      return RepaintBoundary(
        child: CategoryHeaderCard(
          title: category.category.categoryTitle,
          totalSpending: category.totalSpending,
          budgetAmount: category.category.budgetAmount,
          hasBudgetAmount: category.category.hasBudgetAmount,
          icon: category.category.categoryIcon,
          progress: progress,
        ),
      );
    });
  }
}
