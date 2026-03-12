import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';

class CategoryAppBarTitle extends StatelessWidget {
  final String categoryId;

  const CategoryAppBarTitle({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final categoryTitle = context.select<HomeBloc, String>((homeBloc) {
      final categoryIndex = homeBloc.state.model.categories.indexWhere(
        (cat) => cat.source.financialId == categoryId,
      );
      if (categoryIndex == -1) return '';
      return homeBloc
          .state
          .model
          .categories[categoryIndex]
          .source
          .financialTitle;
    });

    return Text(
      categoryTitle,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
