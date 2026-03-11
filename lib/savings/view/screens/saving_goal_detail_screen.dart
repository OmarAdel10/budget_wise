import 'dart:math';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view/screens/edit_saving_goal_screen.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

import '../widgets/saving_day_item.dart';

class SavingGoalDetailScreen extends StatefulWidget {
  static const String routeName = '/saving-goal-detail';
  const SavingGoalDetailScreen({super.key});

  @override
  State<SavingGoalDetailScreen> createState() => _SavingGoalDetailScreenState();
}

class _SavingGoalDetailScreenState extends State<SavingGoalDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _completedHeaderKey = GlobalKey();
  final GlobalKey _todoHeaderKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToCompleted() {
    if (_completedHeaderKey.currentContext != null) {
      Scrollable.ensureVisible(
        _completedHeaderKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _jumpToTodo() {
    if (_todoHeaderKey.currentContext != null) {
      Scrollable.ensureVisible(
        _todoHeaderKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final initialGoal = args['savingGoal'] as SavingsModel;

    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final goal = state.savingsList.firstWhere(
          (g) => g.id == initialGoal.id,
          orElse: () => initialGoal,
        );

        final double progress = (goal.currentAmount / goal.targetAmount).clamp(
          0.0,
          1.0,
        );
        final int percentage = (progress * 100).toInt();

        // Generate Lists
        final List<int> allDays = List.generate(goal.targetDays, (i) => i + 1);
        if (goal.method == SavingsMethod.custom) {
          final existingDays = goal.customAmounts.keys.toList()..sort();
          allDays.clear();
          allDays.addAll(existingDays);
        }

        final uncompletedDays = allDays
            .where((d) => !goal.completedDays.contains(d))
            .toList();
        final completedDays = allDays
            .where((d) => goal.completedDays.contains(d))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            title: Text(goal.name, style: AppTextStyles.heading3),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  PhosphorIconsRegular.pencil,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditSavingGoalScreen.routeName,
                    arguments: {'savingGoal': goal},
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: AppColors.danger,
                ),
                onPressed: () => _showDeleteDialog(context, goal.id),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressHeader(
                    goal: goal,
                    progress: progress,
                    percentage: percentage,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Uncompleted List
                  if (uncompletedDays.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Todo Savings",
                          key: _todoHeaderKey,
                          style: AppTextStyles.heading3,
                        ),
                        if (completedDays.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_downward,
                              color: AppColors.primaryAccent,
                            ),
                            onPressed: _jumpToCompleted,
                            tooltip: "Jump to Completed",
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DaysList(goal: goal, days: uncompletedDays),
                  ],

                  // Completed List
                  if (completedDays.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Completed days",
                          key: _completedHeaderKey,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primaryAccent,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: AppColors.primaryAccent,
                          ),
                          onPressed: _jumpToTodo,
                          tooltip: "Jump to Todo",
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DaysList(
                      goal: goal,
                      days: completedDays,
                      isCompleted: true,
                    ),
                  ],

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
          floatingActionButton: goal.method == SavingsMethod.custom
              ? FloatingActionButton(
                  onPressed: () => _addManualEntry(context, goal),
                  backgroundColor: AppColors.primaryAccent,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  void _addManualEntry(BuildContext context, SavingsModel goal) {
    final nextDay =
        (goal.customAmounts.keys.isEmpty
            ? 0
            : goal.customAmounts.keys.reduce(max)) +
        1;
    context.read<SavingsBloc>().add(
      SavingsEventUpdateCustomAmount(
        goalId: goal.id,
        day: nextDay,
        amount: 0.0,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String goalId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.back),
          ),
          TextButton(
            onPressed: () {
              context.read<SavingsBloc>().add(
                SavingsEventDeleteGoal(goalId: goalId),
              );
              Navigator.pop(context);
              Navigator.pop(context);
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

class _ProgressHeader extends StatelessWidget {
  final SavingsModel goal;
  final double progress;
  final int percentage;
  const _ProgressHeader({
    required this.goal,
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text("Overall Progress", style: AppTextStyles.bodyMedium),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryBackground,
              valueColor: AlwaysStoppedAnimation<Color>(Color(goal.colorValue)),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DaysList extends StatelessWidget {
  final SavingsModel goal;
  final List<int> days;
  final bool isCompleted;
  const _DaysList({
    required this.goal,
    required this.days,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final dayNum = days[index];
        double amount = 0;

        switch (goal.method) {
          case SavingsMethod.defaultPattern:
            amount = dayNum.toDouble();
            break;
          case SavingsMethod.doublePattern:
            amount = dayNum.toDouble() * 2;
            break;
          case SavingsMethod.constant:
            amount = goal.constantAmount ?? 0.0;
            break;
          case SavingsMethod.custom:
            amount = goal.customAmounts[dayNum] ?? 0.0;
            break;
        }

        return SavingDayItem(
          goal: goal,
          dayNum: dayNum,
          amount: amount,
          isCompleted: isCompleted,
        );
      },
    );
  }
}
