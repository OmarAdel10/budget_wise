import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/buckets/view_model/buckets_state.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SavingGoalsListScreen extends StatelessWidget {
  static const String routeName = '/saving-goals-list';
  const SavingGoalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(
          "Saving Goals",
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<BucketsBloc, BucketsState>(
          builder: (context, state) {
            final goals = state.savingsList;

            if (goals.isEmpty) {
              return Center(
                child: Text(
                  "No goals yet",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: goals.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                return _SavingGoalItem(goal: goals[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _SavingGoalItem extends StatelessWidget {
  final SavingGoalModel goal;

  const _SavingGoalItem({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          SavingGoalDetailScreen.routeName,
          arguments: {'savingGoalId': goal.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Color(goal.colorValue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(PhosphorIconsBold.piggyBank, color: Color(goal.colorValue)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} ${goal.currency}",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primaryBackground,
                valueColor: AlwaysStoppedAnimation<Color>(Color(goal.colorValue)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
