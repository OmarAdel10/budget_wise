import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/home/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_state.dart';
import 'package:budget_wise/statistics/view_model/statistics_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _showIncome = false;
  bool _isTrendExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        final totalIncome = state.model.totalIncome;
        final totalExpenses = state.model.totalExpenses;
        final totalSavings = state.model.totalSavings;
        final breakdown = _showIncome
            ? state.model.incomeBreakdown
            : state.model.expenseBreakdown;
        final selectedMonth = state.model.selectedMonth;
        final hasData =
            state.model.incomeBreakdown.isNotEmpty ||
            state.model.expenseBreakdown.isNotEmpty;

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
              // Month Selector (Fixed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        final prevMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month - 1,
                        );
                        context.read<StatisticsBloc>().add(
                          StatisticsEventLoadRequested(prevMonth),
                        );
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMM(
                        Localizations.localeOf(context).languageCode,
                      ).format(selectedMonth),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final nextMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month + 1,
                        );
                        context.read<StatisticsBloc>().add(
                          StatisticsEventLoadRequested(nextMonth),
                        );
                      },
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Top Cards Grid Replacement
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          TransactionTypeDetailScreen.routeName,
                                          arguments: {'type': 'income'},
                                        );
                                      },
                                      child: _buildSummaryCard(
                                        l10n.totalIncome,
                                        totalIncome,
                                        AppColors.income,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          TransactionTypeDetailScreen.routeName,
                                          arguments: {'type': 'outcome'},
                                        );
                                      },
                                      child: _buildSummaryCard(
                                        l10n.totalExpenses,
                                        totalExpenses,
                                        AppColors.expense,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: _buildSummaryCard(
                                  l10n.currentSavings,
                                  totalSavings,
                                  AppColors.savings,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Trend Section
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isTrendExpanded = !_isTrendExpanded;
                                  });
                                },
                                icon: AnimatedRotation(
                                  turns: _isTrendExpanded ? 0 : -0.25,
                                  duration: const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.dailyTrend,
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: _isTrendExpanded
                                ? Container(
                                    height: 250,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                    ),
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      margin: EdgeInsets.zero,
                                      legend: Legend(
                                        isVisible: true,
                                        position: LegendPosition.bottom,
                                        textStyle: AppTextStyles.bodySmall,
                                      ),
                                      primaryXAxis: NumericAxis(
                                        majorGridLines: const MajorGridLines(
                                          width: 0,
                                        ),
                                        interval: 5,
                                        minimum: 1,
                                        maximum: state
                                            .model
                                            .dailyIncomeTrend
                                            .length
                                            .toDouble(),
                                        labelStyle: AppTextStyles.bodySmall,
                                      ),
                                      primaryYAxis: NumericAxis(
                                        majorGridLines: const MajorGridLines(
                                          width: 1,
                                          dashArray: [5, 5],
                                        ),
                                        axisLine: const AxisLine(width: 0),
                                        labelStyle: AppTextStyles.bodySmall,
                                        numberFormat:
                                            NumberFormat.compactCurrency(
                                              symbol: '\$',
                                              decimalDigits: 0,
                                            ),
                                      ),
                                      tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                        header: '',
                                        canShowMarker: true,
                                        format: 'Day point.x: point.y',
                                        duration: 1000,
                                        textStyle: AppTextStyles.bodyMedium,
                                        color: AppColors.cardBackground,
                                        borderColor: AppColors.textPrimary,
                                        borderWidth: 1,
                                      ),
                                      series: <CartesianSeries<double, int>>[
                                        LineSeries<double, int>(
                                          name: l10n.income,
                                          dataSource:
                                              state.model.dailyIncomeTrend,
                                          xValueMapper: (value, index) =>
                                              index + 1,
                                          yValueMapper: (value, _) => value,
                                          color: AppColors.income,
                                          width: 2,
                                          markerSettings: const MarkerSettings(
                                            isVisible: false,
                                            shape: DataMarkerType.circle,
                                            width: 6,
                                            height: 6,
                                            color: Colors.white,
                                            borderWidth: 2,
                                            borderColor: AppColors.income,
                                          ),
                                          enableTooltip: true,
                                        ),
                                        LineSeries<double, int>(
                                          name: l10n.expenses,
                                          dataSource:
                                              state.model.dailyExpenseTrend,
                                          xValueMapper: (value, index) =>
                                              index + 1,
                                          yValueMapper: (value, _) => value,
                                          color: AppColors.expense,
                                          width: 2,
                                          markerSettings: const MarkerSettings(
                                            isVisible: false,
                                            shape: DataMarkerType.circle,
                                            width: 6,
                                            height: 6,
                                            color: Colors.white,
                                            borderWidth: 2,
                                            borderColor: AppColors.expense,
                                          ),
                                          enableTooltip: true,
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppSpacing.xl),

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
                            // Category Share
                            if (breakdown.isNotEmpty) ...[
                              // Category Chart Header + Income/Expense Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.categoryChart,
                                    style: AppTextStyles.heading3,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showIncome = !_showIncome;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.cardBackground,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _showIncome
                                              ? '${l10n.income} '
                                              : '${l10n.expenses} ',
                                          style: TextStyle(
                                            color: _showIncome
                                                ? AppColors.income
                                                : AppColors.expense,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          _showIncome
                                              ? PhosphorIcons.arrowFatLinesUp(
                                                  PhosphorIconsStyle.fill,
                                                )
                                              : PhosphorIcons.arrowFatLinesDown(
                                                  PhosphorIconsStyle.fill,
                                                ),
                                          size: 16,
                                          color: _showIncome
                                              ? AppColors.income
                                              : AppColors.expense,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Category Chart
                              Container(
                                height: MediaQuery.sizeOf(context).height * 0.2,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                child: SfCircularChart(
                                  palette: const [
                                    Color(0xFF65B583),
                                    Color(0xFFE57373),
                                    Color(0xFF81D4FA),
                                    Color(0xFFF48FB1),
                                    Color(0xFF80CBC4),
                                    Color(0xFF90CAF9),
                                    Color(0xFFCE93D8),
                                    Color(0xFFFFF59D),
                                    Color(0xFFFFB74D),
                                    Color(0xFFBA68C8),
                                  ],
                                  tooltipBehavior: TooltipBehavior(
                                    builder:
                                        (
                                          data,
                                          point,
                                          series,
                                          pointIndex,
                                          seriesIndex,
                                        ) {
                                          final item = breakdown[pointIndex];
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      item
                                                          .category
                                                          .categoryIcon,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      item
                                                          .category
                                                          .categoryTitle,
                                                      style: AppTextStyles
                                                          .bodySmall
                                                          .copyWith(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '\$ ${item.totalSpending.toString()}',
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                    duration: 1000,
                                    enable: true,
                                    // format: 'point.x\n\$point.y',
                                    textStyle: AppTextStyles.bodyMedium,
                                    color: AppColors.cardBackground,
                                    borderColor: AppColors.textPrimary,
                                    borderWidth: 1,
                                  ),
                                  series: <CircularSeries>[
                                    PieSeries<CategoriesWithSpending, String>(
                                      radius: '70%',
                                      dataSource: breakdown,
                                      xValueMapper: (data, _) =>
                                          data.category.categoryTitle,
                                      yValueMapper: (data, _) =>
                                          data.totalSpending,
                                      explode: true,
                                      explodeGesture: ActivationMode.singleTap,
                                      selectionBehavior: SelectionBehavior(
                                        enable: true,
                                      ),
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        labelPosition:
                                            ChartDataLabelPosition.outside,
                                        showZeroValue: false,
                                        labelIntersectAction:
                                            LabelIntersectAction.none,
                                        connectorLineSettings:
                                            const ConnectorLineSettings(
                                              length: '20%',
                                              type: ConnectorType.curve,
                                              width: 1,
                                            ),
                                        textStyle: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        builder:
                                            (
                                              data,
                                              point,
                                              series,
                                              index,
                                              pointIndex,
                                            ) {
                                              final item =
                                                  data
                                                      as CategoriesWithSpending;
                                              final total = _showIncome
                                                  ? totalIncome
                                                  : totalExpenses;
                                              final percentage = total > 0
                                                  ? (item.totalSpending /
                                                            total) *
                                                        100
                                                  : 0.0;
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        item
                                                            .category
                                                            .categoryIcon,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item
                                                            .category
                                                            .categoryTitle,
                                                        style: AppTextStyles
                                                            .bodySmall
                                                            .copyWith(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${percentage.toStringAsFixed(1)} %',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(fontSize: 10),
                                                  ),
                                                ],
                                              );
                                            },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],

                            // Header with Filter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _showIncome
                                        ? l10n.earningsByCategory
                                        : l10n.spendingByCategory,
                                    style: AppTextStyles.heading3,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                PopupMenuButton<StatisticsSorting>(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                  popUpAnimationStyle: AnimationStyle(
                                    curve: Curves.easeIn,
                                    reverseCurve: Curves.easeOut,
                                    duration: Duration(milliseconds: 400),
                                    reverseDuration: Duration(
                                      milliseconds: 400,
                                    ),
                                  ),
                                  splashRadius: 40,
                                  color: AppColors.cardBackground,
                                  initialValue: state.model.sortingType,
                                  icon: const Icon(
                                    Icons.sort,
                                    color: AppColors.textSecondary,
                                  ),
                                  onSelected: (type) {
                                    context.read<StatisticsBloc>().add(
                                      StatisticsEventSortChanged(type),
                                    );
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: StatisticsSorting.highestAmount,
                                      child: Text(l10n.sortHighest),
                                    ),
                                    PopupMenuItem(
                                      value: StatisticsSorting.lowestAmount,
                                      child: Text(l10n.sortLowest),
                                    ),
                                    PopupMenuItem(
                                      value: StatisticsSorting.alphabetical,
                                      child: Text(l10n.sortAZ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Category Headers
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.category,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    l10n.amount,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ]),
                      ),
                    ),

                    // Category List
                    if (hasData)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = breakdown[index];
                            final category = item.category;
                            final color = _showIncome
                                ? AppColors.income
                                : AppColors.expense;
                            final total = _showIncome
                                ? totalIncome
                                : totalExpenses;
                            final percentage = total > 0
                                ? (item.totalSpending / total) * 100
                                : 0.0;
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            4.0,
                                          ),
                                        ),
                                        child: Text(
                                          "${percentage.toStringAsFixed(0)}%",
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          category.categoryIcon,
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Text(
                                        category.categoryTitle,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_showIncome ? "+" : "-"}\$${item.totalSpending.toInt()}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, childCount: breakdown.length),
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

  Widget _buildSummaryCard(String title, double amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "\$${amount.toStringAsFixed(0)}",
            style: AppTextStyles.heading3.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
