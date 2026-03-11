import 'dart:math';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view_model/savings_bloc.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingGoalDetailScreen extends StatelessWidget {
  static const String routeName = '/saving-goal-detail';

  const SavingGoalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialGoal = args?['savingGoal'] as SavingsModel;

    return BlocBuilder<SavingsBloc, SavingsState>(
      buildWhen: (previous, current) {
        final prevGoal = previous.savingsList
            .where((g) => g.id == initialGoal.id)
            .firstOrNull;
        final currGoal = current.savingsList
            .where((g) => g.id == initialGoal.id)
            .firstOrNull;
        return prevGoal != currGoal;
      },
      builder: (context, state) {
        final goal =
            state.savingsList
                .where((g) => g.id == initialGoal.id)
                .firstOrNull ??
            initialGoal;

        final double progress = (goal.currentAmount / goal.targetAmount).clamp(
          0.0,
          1.0,
        );
        final int percentage = (progress * 100).toInt();

        // Calculate total days needed using quadratic formula: n^2 + n - 2*target = 0
        // n = (-1 + sqrt(1 + 8 * target)) / 2
        final int totalDaysNeeded = ((-1 + sqrt(1 + 8 * goal.targetAmount)) / 2)
            .ceil();

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              goal.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: AppColors.danger,
                ),
                onPressed: () {
                  _showDeleteDialog(context, goal.id);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Progress
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
                            Text(
                              l10n.progress,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              "$percentage%",
                              style: AppTextStyles.heading3.copyWith(
                                color: Color(goal.colorValue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${goal.currency}${goal.currentAmount.toInt()}",
                              style: AppTextStyles.heading2,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              "/ ${goal.currency}${goal.targetAmount.toInt()}",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.primaryBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(goal.colorValue),
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Daily Savings Section
                  Text(l10n.dailySavings, style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.saveSmallAmountsInfo,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Daily Savings List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalDaysNeeded,
                    itemBuilder: (context, index) {
                      final int dayNum = index + 1;
                      final double amount = dayNum.toDouble();
                      final bool isCompleted = goal.completedDays.contains(
                        dayNum,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: isCompleted
                              ? Border.all(
                                  color: Color(
                                    goal.colorValue,
                                  ).withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "$dayNum",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  "${l10n.day} $dayNum",
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${goal.currency}${amount.toInt()}",
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                GestureDetector(
                                  onTap: () {
                                    context.read<SavingsBloc>().add(
                                      SavingsEventToggleDayContribution(
                                        goalId: goal.id,
                                        day: dayNum,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    isCompleted
                                        ? PhosphorIcons.checkCircle(
                                            PhosphorIconsStyle.fill,
                                          )
                                        : PhosphorIcons.circle(
                                            PhosphorIconsStyle.regular,
                                          ),
                                    color: isCompleted
                                        ? Color(goal.colorValue)
                                        : AppColors.textSecondary,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String goalId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(l10n.deleteAccount, style: AppTextStyles.heading3),
        content: Text(
          l10n.deleteAccountConfirmation,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.back,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<SavingsBloc>().add(
                SavingsEventDeleteGoal(goalId: goalId),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
