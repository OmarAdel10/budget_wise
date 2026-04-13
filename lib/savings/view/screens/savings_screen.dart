import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:budget_wise/shared/constants/dimensions.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

import '../widgets/saving_goal_card.dart';
import 'add_saving_goal_screen.dart';
import 'saving_goal_detail_screen.dart';

class SavingsScreen extends StatelessWidget {
  static const String routeName = '/savings-screen';
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
          buildWhen: (previous, current) =>
              previous.savingsList != current.savingsList,
          builder: (context, state) {
            final savingGoals = state.savingsList;

            if (savingGoals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsBold.piggyBank,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: savingGoals.length,
              itemExtent: AppDimensions.savingGoalItemExtent,
              itemBuilder: (context, index) {
                final goal = savingGoals[index];
                final double progressValue =
                    (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                final int percentage = (progressValue * 100).toInt();

                return SavingGoalCard(
                  goal: goal,
                  formattedProgress: l10n.savingsGoalProgress(percentage),
                  formattedAmount: l10n.savingsGoalAmountProgress(
                    goal.currency,
                    goal.currentAmount,
                    goal.targetAmount,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      SavingGoalDetailScreen.routeName,
                      arguments: {'savingGoalId': goal.id},
                    );
                  },
                  onDelete: () {
                    final savingsBloc = context.read<SavingsBloc>();

                    AppToast.show(
                      context,
                      type: AppToastType.deleteWithUndo,
                      title: l10n.savingDeleted,
                      onCompleted: () {
                        savingsBloc.add(
                          SavingsEventDeleteGoal(goalId: goal.id),
                        );
                      },
                    );
                  },
                );
              },
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
