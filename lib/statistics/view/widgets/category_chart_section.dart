import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/income_expense_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/statistics/data/constants/statistics_constants.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryChartSection extends StatelessWidget {
  final List<CategoriesWithSpending> incomeBreakdown;
  final List<CategoriesWithSpending> expenseBreakdown;
  final ToggleOption toggleType;
  final Function(ToggleOption) onToggle;
  final double totalIncome;
  final double totalExpenses;

  const CategoryChartSection({
    super.key,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.toggleType,
    required this.onToggle,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final breakdown = toggleType == ToggleOption.income
        ? incomeBreakdown
        : expenseBreakdown;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.categoryChart, style: AppTextStyles.heading3),
            IncomeExpenseToggle(
              currentSelection: toggleType,
              onChanged: onToggle,
            ),
          ],
        ),
        SizedBox(
          height: 280,
          child: breakdown.isEmpty
              ? const SizedBox.shrink()
              : SfCircularChart(
                  centerX: '50%',
                  centerY: '50%',
                  tooltipBehavior: TooltipBehavior(
                    builder: (data, point, series, pointIndex, seriesIndex) {
                      final item = breakdown[pointIndex];
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.category.categoryIcon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.category.categoryTitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${NumberFormat.currency(name: context.read<SettingsBloc>().state.model.defaultCurrency).currencySymbol} ${item.totalSpending.toString()}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    duration: 1000,
                    enable: true,
                    textStyle: AppTextStyles.bodyMedium,
                    color: AppColors.cardBackground,
                    borderColor: AppColors.textPrimary,
                    borderWidth: 1,
                  ),
                  series: <CircularSeries>[
                    PieSeries<CategoriesWithSpending, String>(
                      radius: '55%',
                      dataSource: breakdown,
                      xValueMapper: (data, _) => data.category.categoryTitle,
                      yValueMapper: (data, _) => data.totalSpending,
                      pointColorMapper: (data, index) {
                        final colors = toggleType == ToggleOption.income
                            ? StatisticsConstants.incomeColors
                            : StatisticsConstants.expenseColors;
                        return colors[index % colors.length];
                      },
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        showZeroValue: false,
                        labelIntersectAction: LabelIntersectAction.none,
                        connectorLineSettings: const ConnectorLineSettings(
                          length: '20%',
                          type: ConnectorType.curve,
                          width: 1,
                        ),
                        textStyle: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        builder: (data, point, series, index, pointIndex) {
                          final item = data as CategoriesWithSpending;
                          return SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.category.categoryIcon,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.category.categoryTitle,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${item.percentage.toStringAsFixed(1)} %',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
