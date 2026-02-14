import 'package:budget_wise/statistics/view/widgets/category_chart_section.dart';
import 'package:budget_wise/statistics/view/widgets/category_list_section.dart';
import 'package:budget_wise/statistics/view/widgets/month_selector.dart';
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
  late final ValueNotifier<bool> _showIncomeNotifier;
  late final ValueNotifier<bool> _isTrendExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _showIncomeNotifier = ValueNotifier<bool>(false);
    _isTrendExpandedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _showIncomeNotifier.dispose();
    _isTrendExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (previous, current) => previous.model != current.model,
      builder: (context, state) {
        final model = state.model;
        final hasData =
            model.incomeBreakdown.isNotEmpty ||
            model.expenseBreakdown.isNotEmpty;

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
              MonthSelector(
                selectedMonth: model.selectedMonth,
                onPrevious: () {
                  final prevMonth = DateTime(
                    model.selectedMonth.year,
                    model.selectedMonth.month - 1,
                  );
                  context.read<StatisticsBloc>().add(
                    StatisticsEventLoadRequested(prevMonth),
                  );
                },
                onNext: () {
                  final nextMonth = DateTime(
                    model.selectedMonth.year,
                    model.selectedMonth.month + 1,
                  );
                  context.read<StatisticsBloc>().add(
                    StatisticsEventLoadRequested(nextMonth),
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
                          SummaryCards(
                            totalIncome: model.totalIncome,
                            totalExpenses: model.totalExpenses,
                            totalSavings: model.totalSavings,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TrendChartSection(
                            dailyIncomeTrend: model.dailyIncomeTrend,
                            dailyExpenseTrend: model.dailyExpenseTrend,
                            isTrendExpandedNotifier: _isTrendExpandedNotifier,
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isTrendExpandedNotifier,
                            builder: (context, isExpanded, child) {
                              return isExpanded
                                  ? const SizedBox(height: AppSpacing.xl)
                                  : const SizedBox.shrink();
                            },
                          ),
                          if (!hasData)
                            Padding(
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
                            )
                          else ...[
                            CategoryChartSection(
                              incomeBreakdown: model.incomeBreakdown,
                              expenseBreakdown: model.expenseBreakdown,
                              showIncomeNotifier: _showIncomeNotifier,
                              totalIncome: model.totalIncome,
                              totalExpenses: model.totalExpenses,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CategoryListSection(
                              incomeBreakdown: model.incomeBreakdown,
                              expenseBreakdown: model.expenseBreakdown,
                              showIncomeNotifier: _showIncomeNotifier,
                              totalIncome: model.totalIncome,
                              totalExpenses: model.totalExpenses,
                              currentSorting: model.sortingType,
                              onSortChanged: (type) {
                                context.read<StatisticsBloc>().add(
                                  StatisticsEventSortChanged(type),
                                );
                              },
                            ),
                          ],
                        ]),
                      ),
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
      },
    );
  }
}
