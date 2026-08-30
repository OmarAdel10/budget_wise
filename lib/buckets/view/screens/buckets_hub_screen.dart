import 'package:budget_wise/buckets/view/screens/budgets_list_screen.dart';
import 'package:budget_wise/buckets/view/screens/saving_goals_list_screen.dart';
import 'package:budget_wise/buckets/view/screens/unbudgeted_categories_screen.dart';
import 'package:budget_wise/buckets/view_model/buckets_state.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BucketsHubScreen extends StatelessWidget {
  static const String routeName = '/buckets-hub';
  const BucketsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(
          "Buckets",
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<BucketsBloc, BucketsState>(
          builder: (context, bucketState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, catState) {
                final unbudgetedCount = catState.categoriesList
                    .where((c) => !c.hasBudgetAmount)
                    .length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _SummaryHeader(
                        budgetsCount: catState.categoriesList
                            .where((c) => c.hasBudgetAmount)
                            .length,
                        goalsCount: bucketState.savingsList.length,
                        budgetUsedPercent: 54, // TODO: Computed logic
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _UnbudgetedAlertCard(
                        hasUnbudgeted: unbudgetedCount > 0,
                        onReview: () {
                          Navigator.of(
                            context,
                          ).pushNamed(UnbudgetedCategoriesScreen.routeName);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _NavigationCard(
                        title: "Budgeting",
                        subtitle: "Manage your category spending",
                        icon: PhosphorIconsBold.wallet,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(BudgetsListScreen.routeName);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NavigationCard(
                        title: "Saving Goals",
                        subtitle: "Track your progress",
                        icon: PhosphorIconsBold.piggyBank,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(SavingGoalsListScreen.routeName);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int budgetsCount;
  final int goalsCount;
  final int budgetUsedPercent;

  const _SummaryHeader({
    required this.budgetsCount,
    required this.goalsCount,
    required this.budgetUsedPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric(label: "Budgets", value: "$budgetsCount"),
          _Metric(label: "Goals", value: "$goalsCount"),
          _Metric(label: "Used", value: "$budgetUsedPercent%"),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UnbudgetedAlertCard extends StatelessWidget {
  final bool hasUnbudgeted;
  final VoidCallback onReview;

  const _UnbudgetedAlertCard({
    required this.hasUnbudgeted,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasUnbudgeted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsBold.warningCircle,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              "You have unbudgeted spending. Review categories to set limits.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text("Review"),
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primaryAccent),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
