import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view/screens/add_category_screen.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/category_list_item.dart';
import 'package:budget_wise/shared/widgets/income_expense_toggle.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeCategoriesSection extends StatefulWidget {
  const HomeCategoriesSection({super.key});

  @override
  State<HomeCategoriesSection> createState() => _HomeCategoriesSectionState();
}

class _HomeCategoriesSectionState extends State<HomeCategoriesSection> {
  late final ValueNotifier<ToggleOption> _showIncomeNotifier;

  @override
  void initState() {
    super.initState();
    _showIncomeNotifier = ValueNotifier<ToggleOption>(ToggleOption.expense);
  }

  @override
  void dispose() {
    _showIncomeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ToggleOption>(
      valueListenable: _showIncomeNotifier,
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
                _HomeCategoriesHeader(showIncomeNotifier: _showIncomeNotifier),
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
    final l10n = AppLocalizations.of(context)!;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.categories, style: AppTextStyles.heading3),
            const Spacer(),
            IncomeExpenseToggle(
              selectionNotifier: showIncomeNotifier,
              isScaled: true,
              scaleY: 0.90,
              scaleX: 0.85,
            ),
            IconButton(
              tooltip: l10n.addCategory,
              onPressed: () {
                Navigator.of(context).pushNamed(AddCategoryScreen.routeName);
              },
              icon: Icon(
                PhosphorIcons.plus(PhosphorIconsStyle.bold),
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          final item = categoryData[index];
          final category = item.source as CategoryModel;
          final hasBudget = category.hasBudgetAmount;
          final budget = category.budgetAmount ?? 0;
          final spending = item.amount;
          final isIncome = category.type == TransactionType.income;

          double? progress;
          if (hasBudget && budget > 0) {
            progress = spending / budget;
          }

          return CategoryListItem(
            key: ValueKey(category.id),
            name: category.categoryTitle,
            amount: spending.toStringAsFixed(0),
            totalBudget: budget.toStringAsFixed(0),
            hasBudgetAmount: hasBudget,
            isIncome: isIncome,
            icon: category.categoryIcon,
            progress: progress,
            index: index,
            onDelete: () => _handleDelete(context, item),
            onTap: () => Navigator.of(context).pushNamed(
              CategoryDetailScreen.routeName,
              arguments: {
                'categoryId': category.id,
                'progress': progress,
              },
            ),
          );
        },
        itemCount: categoryData.length,
        onReorder: (oldIndex, newIndex) {
          context.read<CategoryBloc>().add(
            CategoryEventReorder(oldIndex: oldIndex, newIndex: newIndex),
          );
        },
      ),
    );
  }

  void _handleDelete(
    BuildContext context,
    FinancialBreakdownItem item,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final catBloc = context.read<CategoryBloc>();
    final category = item.source as CategoryModel;

    AppToast.show(
      context,
      type: AppToastType.deleteWithUndo,
      title: l10n.categoryDeleted,
      onCompleted: () {
        catBloc.add(
          CategoryEventDeleteCategory(categoryId: category.id),
        );
      },
    );
  }
}
