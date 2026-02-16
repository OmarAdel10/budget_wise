import 'package:budget_wise/home/view/screens/add_category_screen.dart';
import 'package:budget_wise/home/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:toastification/toastification.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const String routeName = '/category-detail';

  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final categoryId = args['categoryId'];

        final categoryIndex = state.model.categories.indexWhere(
          (cat) => cat.category.id == categoryId,
        );

        if (categoryIndex == -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final category = state.model.categories[categoryIndex];
        final recentTransactionsList = state.model.transactions
            .where(
              (expense) =>
                  expense.categoryId == categoryId
            )
            .toList();

        final budget = category.category.budgetAmount ?? 0;
        final spending = category.totalSpending;

        double? progress;
        if (category.category.hasBudgetAmount && budget > 0) {
          progress = spending / budget;
        }
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              category.category.categoryTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddCategoryScreen(categoryToEdit: category.category),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: AppColors.danger,
                ),
                onPressed: () {
                  final catBloc = context.read<CategoryBloc>();

                  toastification.show(
                    context: context,
                    type: ToastificationType.warning,
                    style: ToastificationStyle.flatColored,
                    autoCloseDuration: const Duration(seconds: 3),
                    title: Text(l10n.categoryDeleted),
                    closeButton: ToastCloseButton(
                      showType: CloseButtonShowType.always,
                      buttonBuilder: (context, onClose) {
                        return GestureDetector(
                          onTap: onClose,
                          child: Text(l10n.undo, style: AppTextStyles.button),
                        );
                      },
                    ),
                    callbacks: ToastificationCallbacks(
                      onAutoCompleteCompleted: (item) {
                        catBloc.add(
                          CategoryEventDeleteCategory(categoryId: categoryId),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.totalSpent,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${category.totalSpending.toInt()}",
                                      style: AppTextStyles.heading2,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      category.category.hasBudgetAmount
                                          ? "/ \$${category.category.budgetAmount?.toInt() ?? 0}"
                                          : '',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(category.category.categoryIcon, size: 40),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Progress Bar with percentage
                        if (progress != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    backgroundColor:
                                        AppColors.primaryBackground,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress > 1.0
                                          ? Colors.red
                                          : AppColors.primaryAccent,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${(progress * 100).clamp(0, 999).toInt()}%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: progress > 1.0
                                      ? Colors.red
                                      : AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Expenses List Header
                  Text(l10n.recentExpenses, style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.md),

                  // Expenses List
                  recentTransactionsList.isNotEmpty
                      ? Expanded(
                          child: ListView.separated(
                            itemCount: recentTransactionsList.length,
                            itemBuilder: (context, index) {
                              final expense = recentTransactionsList[index];
                              return TransactionListItem(model: expense);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.sm),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                l10n.noRecentTransactionsFound,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
