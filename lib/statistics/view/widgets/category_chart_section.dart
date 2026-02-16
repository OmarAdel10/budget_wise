import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/statistics/data/constants/statistics_constants.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryChartSection extends StatelessWidget {
  final List<CategoriesWithSpending> incomeBreakdown;
  final List<CategoriesWithSpending> expenseBreakdown;
  final ValueNotifier<bool> showIncomeNotifier;
  final double totalIncome;
  final double totalExpenses;

  const CategoryChartSection({
    super.key,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.showIncomeNotifier,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.categoryChart, style: AppTextStyles.heading3),
            ValueListenableBuilder<bool>(
              valueListenable: showIncomeNotifier,
              builder: (context, showIncomeValue, child) {
                return TextButton(
                  onPressed: () {
                    showIncomeNotifier.value = !showIncomeNotifier.value;
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showIncomeValue
                            ? '${l10n.income} '
                            : '${l10n.expenses} ',
                        style: TextStyle(
                          color: showIncomeValue
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        showIncomeValue
                            ? PhosphorIcons.arrowFatLinesUp(
                                PhosphorIconsStyle.fill,
                              )
                            : PhosphorIcons.arrowFatLinesDown(
                                PhosphorIconsStyle.fill,
                              ),
                        size: 16,
                        color: showIncomeValue
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(
          height: 280,
          child: ValueListenableBuilder<bool>(
            valueListenable: showIncomeNotifier,
            builder: (context, showIncomeValue, child) {
              final breakdown = showIncomeValue
                  ? incomeBreakdown
                  : expenseBreakdown;
              if (breakdown.isEmpty) return const SizedBox.shrink();

              return SfCircularChart(
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
                      final colors = showIncomeValue
                          ? StatisticsConstants.incomeColors
                          : StatisticsConstants.expenseColors;
                      return colors[index % colors.length];
                    },
                    // explode: true,
                    // explodeGesture: ActivationMode.singleTap,
                    // selectionBehavior: SelectionBehavior(enable: true),
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
                        final total = showIncomeValue
                            ? totalIncome
                            : totalExpenses;
                        final percentage = total > 0
                            ? (item.totalSpending / total) * 100
                            : 0.0;
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
                                '${percentage.toStringAsFixed(1)} %',
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
              );
            },
          ),
        ),
      ],
    );
  }
}
