import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/statistics/data/constants/statistics_constants.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryChartSection extends StatelessWidget {
  final List<FinancialBreakdownItem> incomeBreakdown;
  final List<FinancialBreakdownItem> expenseBreakdown;
  final List<FinancialBreakdownItem> savingsBreakdown;
  final List<FinancialBreakdownItem> subscriptionBreakdown;
  final ToggleOption toggleType;
  final Function(ToggleOption) onToggle;
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double totalSubscriptions;

  const CategoryChartSection({
    super.key,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.savingsBreakdown,
    required this.subscriptionBreakdown,
    required this.toggleType,
    required this.onToggle,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final List<FinancialBreakdownItem> breakdown;
    switch (toggleType) {
      case ToggleOption.income:
        breakdown = incomeBreakdown;
        break;
      case ToggleOption.expense:
        breakdown = expenseBreakdown;
        break;
      case ToggleOption.transfer:
        breakdown = []; // Handle transfer if added later
        break;
      case ToggleOption.savings:
        breakdown = savingsBreakdown;
        break;
      case ToggleOption.subscription:
        breakdown = subscriptionBreakdown;
        break;
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(context.l10n.chart, style: AppTextStyles.heading3),
        ),
        SizedBox(
          height: 280,
          child: breakdown.isEmpty
              ? const SizedBox.shrink()
              : SfCircularChart(
                  margin: const EdgeInsets.all(10),
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
                                  item.source.financialIcon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.source.financialTitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${NumberFormat.currency(name: context.read<SettingsBloc>().state.model.defaultCurrency).currencySymbol} ${item.amount.toString()}',
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
                    PieSeries<FinancialBreakdownItem, String>(
                      radius: '50%',
                      dataSource: breakdown,
                      xValueMapper: (data, _) => data.source.financialTitle,
                      yValueMapper: (data, _) => data.amount,
                      pointColorMapper: (data, index) {
                        //* if the model provides a colors (like Savings), use it!
                        if (data.source.financialColor != null) {
                          return data.source.financialColor;
                        }

                        //* Otherwise fallback to the constants color logic.
                        final List<Color> colors;
                        switch (toggleType) {
                          case ToggleOption.income:
                            colors = StatisticsConstants.incomeColors;
                            break;
                          case ToggleOption.expense:
                            colors = StatisticsConstants.expenseColors;
                            break;
                          case ToggleOption.transfer:
                            colors =
                                StatisticsConstants.savingsColors; // Fallback
                            break;
                          case ToggleOption.savings:
                            colors = StatisticsConstants.savingsColors;
                            break;
                          case ToggleOption.subscription:
                            colors = StatisticsConstants.subscriptionColors;
                            break;
                        }
                        return colors[index % colors.length];
                      },
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        showZeroValue: false,
                        labelIntersectAction: LabelIntersectAction.shift,
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
                          final item = data as FinancialBreakdownItem;
                          return SizedBox(
                            width: 80,
                            height: 45,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.source.financialIcon,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.source.financialTitle,
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
