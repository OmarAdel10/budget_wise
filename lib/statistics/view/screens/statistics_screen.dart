import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/statistics/view/widgets/category_chart_section.dart';
import 'package:budget_wise/statistics/view/widgets/category_list_section.dart';
import 'package:budget_wise/shared/widgets/month_selector.dart';
import 'package:budget_wise/statistics/view/widgets/summary_cards.dart';
import 'package:budget_wise/statistics/view/widgets/trend_chart_section.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_state.dart';
import 'package:budget_wise/statistics/view_model/statistics_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final ValueNotifier<bool> _isTrendExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _isTrendExpandedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _isTrendExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statisticsBloc = context.read<StatisticsBloc>();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.financialStatistics,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          BlocSelector<StatisticsBloc, StatisticsState, DateTime>(
            selector: (state) => state.model.selectedMonth,
            builder: (context, selectedMonth) {
              return MonthSelector(
                selectedMonth: selectedMonth,
                onPrevious: () {
                  final prevMonth = DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  );
                  statisticsBloc.add(StatisticsEventLoadRequested(prevMonth));
                },
                onNext: () {
                  final nextMonth = DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                  );
                  statisticsBloc.add(StatisticsEventLoadRequested(nextMonth));
                },
              );
            },
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      BlocSelector<
                        StatisticsBloc,
                        StatisticsState,
                        (double, double, double, double)
                      >(
                        selector: (state) => (
                          state.model.totalIncome,
                          state.model.totalExpenses,
                          state.model.totalSavings,
                          state.model.totalSubscriptions,
                        ),
                        builder: (context, data) {
                          return SummaryCards(
                            totalIncome: data.$1,
                            totalExpenses: data.$2,
                            totalSavings: data.$3,
                            totalSubscriptions: data.$4,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BlocSelector<
                        StatisticsBloc,
                        StatisticsState,
                        (List<double>, List<double>)
                      >(
                        selector: (state) => (
                          state.model.dailyIncomeTrend,
                          state.model.dailyExpenseTrend,
                        ),
                        builder: (context, data) {
                          return TrendChartSection(
                            dailyIncomeTrend: data.$1,
                            dailyExpenseTrend: data.$2,
                            isTrendExpandedNotifier: _isTrendExpandedNotifier,
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isTrendExpandedNotifier,
                        builder: (context, isExpanded, child) {
                          return isExpanded
                              ? const SizedBox(height: AppSpacing.xl)
                              : const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<StatisticsBloc, StatisticsState>(
                        buildWhen: (previous, current) =>
                            previous.model.incomeBreakdown !=
                                current.model.incomeBreakdown ||
                            previous.model.expenseBreakdown !=
                                current.model.expenseBreakdown ||
                            previous.model.toggleType !=
                                current.model.toggleType,
                        builder: (context, state) {
                          final model = state.model;
                          final hasData =
                              model.incomeBreakdown.isNotEmpty ||
                              model.expenseBreakdown.isNotEmpty;

                          if (!hasData) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xl * 2,
                              ),
                              child: Center(
                                child: Text(
                                  l10n.noDataThisMonth,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              CategoryChartSection(
                                incomeBreakdown: model.incomeBreakdown,
                                expenseBreakdown: model.expenseBreakdown,
                                toggleType: model.toggleType,
                                totalIncome: model.totalIncome,
                                totalExpenses: model.totalExpenses,
                                onToggle: (type) {
                                  statisticsBloc.add(
                                    StatisticsEventToggleType(type),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              CategoryListHeader(
                                toggleType: model.toggleType,
                                currentSorting: model.sortingType,
                                onSortChanged: (type) {
                                  statisticsBloc.add(
                                    StatisticsEventSortChanged(type),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  buildWhen: (previous, current) =>
                      previous.model.incomeBreakdown !=
                          current.model.incomeBreakdown ||
                      previous.model.expenseBreakdown !=
                          current.model.expenseBreakdown ||
                      previous.model.toggleType != current.model.toggleType,
                  builder: (context, state) {
                    final model = state.model;
                    final breakdown = model.toggleType == ToggleOption.income
                        ? model.incomeBreakdown
                        : model.expenseBreakdown;

                    if (breakdown.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: CategoryListSliver(
                        breakdown: breakdown,
                        toggleType: model.toggleType,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
