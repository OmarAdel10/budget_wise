import 'dart:math';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view/screens/edit_saving_goal_screen.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

import '../widgets/saving_days_sliver_list.dart';
import '../widgets/saving_progress_header.dart';
import '../widgets/saving_section_header.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final initialGoal = args['savingGoal'] as SavingsModel;

    return MultiBlocListener(
      listeners: [
        BlocListener<SavingsBloc, SavingsState>(
          listener: (context, state) {
            if (state is SavingsStateError &&
                state.message == 'insufficient_funds') {
              AppToast.show(
                context,
                type: AppToastType.error,
                title: l10n.insufficientFundsForSaving,
              );
            }
          },
        ),
        BlocListener<SavingsBloc, SavingsState>(
          listener: (context, state) {
            if (state is SavingsStateSuccess && state.showCompletionToast) {
              AppToast.show(
                context,
                type: AppToastType.success,
                title: l10n.savingsGoalCompleted(state.completedGoalName ?? ''),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SavingsBloc, SavingsState>(
        buildWhen: (previous, current) {
          final prevGoal = previous.savingsList.firstWhere(
            (g) => g.id == initialGoal.id,
            orElse: () => initialGoal,
          );
          final currGoal = current.savingsList.firstWhere(
            (g) => g.id == initialGoal.id,
            orElse: () => initialGoal,
          );
          return prevGoal != currGoal;
        },
        builder: (context, state) {
          final goal = state.savingsList.firstWhere(
            (g) => g.id == initialGoal.id,
            orElse: () => initialGoal,
          );

          final double progress = (goal.currentAmount / goal.targetAmount)
              .clamp(0.0, 1.0);
          final int percentage = (progress * 100).toInt();

          final uncompletedDays = goal.uncompletedDaysList;
          final completedDays = goal.completedDaysList;

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
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: SavingProgressHeader(
                        goal: goal,
                        progress: progress,
                        percentage: percentage,
                      ),
                    ),
                  ),

                  // Uncompleted List
                  if (uncompletedDays.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SavingSectionHeader(
                          title: l10n.todoSavings,
                          headerKey: _todoHeaderKey,
                          onJumpPressed: completedDays.isNotEmpty
                              ? _jumpToCompleted
                              : null,
                          tooltip: "Jump to Completed",
                          icon: Icons.arrow_downward,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SavingDaysSliverList(
                        goal: goal,
                        days: uncompletedDays,
                      ),
                    ),
                  ],

                  // Completed List
                  if (completedDays.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xl),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SavingSectionHeader(
                          title: l10n.completedDaysLabel,
                          headerKey: _completedHeaderKey,
                          onJumpPressed: _jumpToTodo,
                          tooltip: "Jump to Todo",
                          icon: Icons.arrow_upward,
                          titleColor: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SavingDaysSliverList(
                        goal: goal,
                        days: completedDays,
                        isCompleted: true,
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
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
      ),
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
