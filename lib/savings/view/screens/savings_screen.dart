import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/view_model/savings_bloc.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

import 'add_saving_goal_screen.dart';
import 'saving_goal_detail_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.navSavings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SavingsBloc, SavingsState>(
          builder: (context, state) {
            final savingGoals = state.savingsList;

            if (savingGoals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noSavingsGoalsThisMonth,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: savingGoals.length,
                    itemBuilder: (context, index) {
                      final goal = savingGoals[index];
                      final double progress =
                          (goal.currentAmount / goal.targetAmount).clamp(
                            0.0,
                            1.0,
                          );
                      final int percentage = (progress * 100).toInt();

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            SavingGoalDetailScreen.routeName,
                            arguments: {'savingGoal': goal},
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    goal.name,
                                    style: AppTextStyles.heading3,
                                  ),
                                  Text(
                                    "$percentage%",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primaryAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Text(
                                    "${goal.currency}${goal.currentAmount.toInt()}",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    " / ${goal.currency}${goal.targetAmount.toInt()}",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppColors.primaryBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(goal.colorValue),
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "savings_fab",
        onPressed: () {
          Navigator.of(context).pushNamed(AddSavingGoalScreen.routeName);
        },
        backgroundColor: AppColors.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
