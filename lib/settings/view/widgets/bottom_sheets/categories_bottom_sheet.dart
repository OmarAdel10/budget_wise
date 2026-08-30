import 'package:budget_wise/category/view/screens/add_category_bottom_sheet.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/category_list_item.dart';
import 'package:budget_wise/shared/widgets/type_tab_bar.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CategoriesBottomSheet extends StatefulWidget {
  const CategoriesBottomSheet({super.key});

  @override
  State<CategoriesBottomSheet> createState() => _CategoriesBottomSheetState();
}

class _CategoriesBottomSheetState extends State<CategoriesBottomSheet> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.only(top: AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: Navigator(
          key: _navKey,
          onGenerateRoute: (settings) => BottomSheetService.pageRoute(
            child: (context) => _CategoryBottomSheetContent(),
          ),
        ),
      ),
    );
  }
}

class _CategoryBottomSheetContent extends StatelessWidget {
  const _CategoryBottomSheetContent();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: BottomSheetService.header(
              title: context.l10n.categories,
              isRoot: true,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    BottomSheetService.pageRoute(
                      child: (context) => AddCategoryBottomSheet(),
                    ),
                  ),
                  icon: const Icon(
                    PhosphorIconsBold.plus,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: TypeTabBar.forToggleOptions(
              isScrollable: false,
              options: const [
                ToggleOption.income,
                ToggleOption.expense,
                ToggleOption.transfer,
              ],
              views: [
                _CategoryList(type: TransactionType.income),
                _CategoryList(type: TransactionType.expense),
                _CategoryList(type: TransactionType.transfer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final TransactionType type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    final transactionsList = context
        .select<TransactionBloc, List<TransactionModel>>(
          (bloc) => bloc.state.transactionsList,
        );
    return BlocBuilder<CategoryBloc, CategoryState>(
      buildWhen: (previous, current) =>
          previous.categoriesList != current.categoriesList &&
          previous.totalSpentById != current.totalSpentById,
      builder: (context, state) {
        final categories = state.categoriesList
            .where((cat) => cat.type == type)
            .toList();

        if (categories.isEmpty) {
          return const Center(
            child: Text(
              'No categories found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final int totalTransactionNumberPerCategory = transactionsList
                .where((trans) => trans.categoryId == category.id)
                .length;
            final title = category.categoryTitle
                .trim()
                .replaceAll('_', ' ')
                .replaceAll(RegExp(r'\b(and)\b'), '&')
                .toTitleCase();

            bool isOverBudget = false;
            if (category.hasBudgetAmount && category.budgetAmount != null) {
              isOverBudget =
                  (state.totalSpentById[category.id] ?? 0.0) >=
                  category.budgetAmount!;
            }

            return CategoryListItem(
              name: title,
              totalNumberOfTransaction: totalTransactionNumberPerCategory,
              totalSpent: state.totalSpentById[category.id] ?? 0.0,
              icon: category.categoryIcon,
              type: category.type,
              isOverBudget: isOverBudget,
              onTap: () {
                Navigator.of(context).push(
                  BottomSheetService.pageRoute(
                    child: (context) =>
                        CategoryDetailScreen(categoryId: category.id),
                  ),
                );
              },
              onDelete: category.isDefault
                  ? null
                  : () {
                      final catBloc = context.read<CategoryBloc>();
                      catBloc.add(
                        CategoryEventDeleteCategory(categoryId: category.id),
                      );
                    },
            );
          },
        );
      },
    );
  }
}
