import 'dart:math';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/view/screens/edit_saving_goal_screen.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/buckets/view_model/buckets_event.dart';
import 'package:budget_wise/buckets/view_model/buckets_state.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../widgets/saving_days_sliver_list.dart';
import '../widgets/saving_progress_header.dart';
import '../widgets/saving_section_header.dart';

class SavingGoalDetailScreen extends StatefulWidget {
  static const String routeName = '/saving-goal-detail';
  final String savingGoalId;

  const SavingGoalDetailScreen({super.key, required this.savingGoalId});

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
    final goal = context.select<BucketsBloc, SavingGoalModel?>(
      (bloc) => bloc.state.savingsList
          .where((g) => g.id == widget.savingGoalId)
          .firstOrNull,
    );

    if (goal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const Scaffold(backgroundColor: AppColors.primaryBackground);
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<BucketsBloc, BucketsState>(
          listener: (context, state) {
            if (state is BucketsStateError &&
                state.message == 'insufficient_funds') {
              AppToast.show(
                context,
                type: AppToastType.error,
                title: context.l10n.insufficientFundsForSaving,
              );
            }
          },
        ),
        BlocListener<BucketsBloc, BucketsState>(
          listener: (context, state) {
            if (state is BucketsStateSuccess && state.showCompletionToast) {
              AppToast.show(
                context,
                type: AppToastType.success,
                title: context.l10n.savingsGoalCompleted(
                  state.completedGoalName ?? '',
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
              icon: Icon(PhosphorIconsRegular.trash, color: AppColors.danger),
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
                    progress: (goal.currentAmount / goal.targetAmount).clamp(
                      0.0,
                      1.0,
                    ),
                    percentage:
                        ((goal.currentAmount / goal.targetAmount).clamp(
                                  0.0,
                                  1.0,
                                ) *
                                100)
                            .toInt(),
                  ),
                ),
              ),

              // Uncompleted List
              if (goal.uncompletedDaysList.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SavingSectionHeader(
                      title: context.l10n.todoSavings,
                      headerKey: _todoHeaderKey,
                      onJumpPressed: goal.completedDaysList.isNotEmpty
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
                    days: goal.uncompletedDaysList,
                  ),
                ),
              ],

              // Completed List
              if (goal.completedDaysList.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SavingSectionHeader(
                      title: context.l10n.completedDaysLabel,
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
                    days: goal.completedDaysList,
                    isCompleted: true,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
        floatingActionButton: goal.method == SavingGoalMethod.custom
            ? FloatingActionButton(
                onPressed: () => _addManualEntry(context, goal),
                backgroundColor: AppColors.primaryAccent,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  void _addManualEntry(BuildContext context, SavingGoalModel goal) {
    final nextDay =
        (goal.customAmounts.keys.isEmpty
            ? 0
            : goal.customAmounts.keys.reduce(max)) +
        1;
    context.read<BucketsBloc>().add(
      BucketsEventUpdateCustomAmount(
        goalId: goal.id,
        day: nextDay,
        amount: 0.0,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(context.l10n.deleteGoal),
        content: Text(context.l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.back),
          ),
          TextButton(
            onPressed: () {
              context.read<BucketsBloc>().add(
                BucketsEventDeleteGoal(goalId: goalId),
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
