import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnbudgetedCategoriesScreen extends StatelessWidget {
  static const String routeName = '/unbudgeted-categories';
  const UnbudgetedCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(
          "Unbudgeted",
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final unbudgeted = state.categoriesList
                .where((c) => !c.hasBudgetAmount)
                .toList();

            if (unbudgeted.isEmpty) {
              return Center(
                child: Text(
                  "All categories are budgeted!",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: unbudgeted.length,
              separatorBuilder: (ctx, i) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final category = unbudgeted[index];
                return _CategoryReviewItem(
                  category: category,
                  onSetBudget: () => _showBudgetBottomSheet(context, category),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showBudgetBottomSheet(BuildContext context, CategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _BudgetBottomSheet(category: category),
    );
  }
}

class _CategoryReviewItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onSetBudget;

  const _CategoryReviewItem({
    required this.category,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.categoryIcon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              category.categoryTitle,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(onPressed: onSetBudget, child: const Text("Set Budget")),
        ],
      ),
    );
  }
}

class _BudgetBottomSheet extends StatefulWidget {
  final CategoryModel category;
  const _BudgetBottomSheet({required this.category});

  @override
  State<_BudgetBottomSheet> createState() => _BudgetBottomSheetState();
}

class _BudgetBottomSheetState extends State<_BudgetBottomSheet> {
  final _amountNotifier = ValueNotifier<String>("");
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _amountNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Set budget for ${widget.category.categoryTitle}",
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTextStyles.heading2,
            decoration: const InputDecoration(hintText: "Enter amount"),
            onChanged: (val) => _amountNotifier.value = val,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<String>(
              valueListenable: _amountNotifier,
              builder: (context, amount, _) {
                return ElevatedButton(
                  onPressed: amount.isEmpty
                      ? null
                      : () {
                          context.read<CategoryBloc>().add(
                            CategoryEventUpdateCategory(
                              widget.category.copyWith(
                                budgetAmount: double.tryParse(amount),
                                hasBudgetAmount: true,
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  child: const Text("Save Budget"),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
