import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view/screens/add_category_bottom_sheet.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/category_list_item.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeCategoriesSection extends StatelessWidget {
  final ValueNotifier<ToggleOption> showIncomeNotifier;
  const HomeCategoriesSection({super.key, required this.showIncomeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ToggleOption>(
      valueListenable: showIncomeNotifier,
      builder: (context, currentSelectedOption, child) {
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.model.categories != current.model.categories,
          builder: (context, state) {
            final categoryData = state.model.categories.where((item) {
              if (item.source is! CategoryModel) return false;
              final cat = item.source as CategoryModel;
              if (currentSelectedOption == ToggleOption.income) {
                return cat.type == TransactionType.income;
              } else {
                return cat.type == TransactionType.expense;
              }
            }).toList();

            return SliverMainAxisGroup(
              slivers: [
                _HomeCategoriesHeader(showIncomeNotifier: showIncomeNotifier),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sm),
                ),
                _HomeCategoriesList(categoryData: categoryData),
              ],
            );
          },
        );
      },
    );
  }
}

class _HomeCategoriesHeader extends StatelessWidget {
  const _HomeCategoriesHeader({required this.showIncomeNotifier});

  final ValueNotifier<ToggleOption> showIncomeNotifier;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.categories, style: AppTextStyles.heading3),
            const Spacer(),
            IconButton(
              tooltip: context.l10n.addCategory,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => const AddCategoryBottomSheet(),
                );
              },
              icon: Icon(
                PhosphorIconsBold.plus,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoriesList extends StatelessWidget {
  const _HomeCategoriesList({required this.categoryData});

  final List<FinancialBreakdownItem> categoryData;

  @override
  Widget build(BuildContext context) {
    final totalSpentById = context.select<CategoryBloc, Map<String, double>>(
      (bloc) => bloc.state.totalSpentById,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = categoryData[index];
          final category = item.source as CategoryModel;
          return; //! Implement If Needed
          // return CategoryListItem(
          //   key: ValueKey(category.id),
          //   name: category.categoryTitle,
          //   totalSpent: totalSpentById[category.id] ?? 0.0,
          //   //! Implement If Needed
          //   totalNumberOfTransaction: 0,
          //   type: category.type,
          //   icon: category.categoryIcon,
          //   onDelete: () => _handleDelete(context, item),
          //   onTap: () => Navigator.of(context).pushNamed(
          //     CategoryDetailScreen.routeName,
          //     arguments: {'categoryId': category.id},
          //   ),
          // );
        }, childCount: categoryData.length),
      ),
    );
  }

  void _handleDelete(BuildContext context, FinancialBreakdownItem item) {
    final catBloc = context.read<CategoryBloc>();
    final category = item.source as CategoryModel;

    AppToast.show(
      context,
      type: AppToastType.deleteWithUndo,
      title: context.l10n.categoryDeleted,
      onCompleted: () {
        catBloc.add(CategoryEventDeleteCategory(categoryId: category.id));
      },
    );
  }
}
