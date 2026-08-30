import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TrendChartSection extends StatelessWidget {
  final List<double> dailyIncomeTrend;
  final List<double> dailyExpenseTrend;
  final List<double> dailySavingsTrend;
  final List<double> dailySubscriptionTrend;
  final ValueNotifier<bool> isTrendExpandedNotifier;

  const TrendChartSection({
    super.key,
    required this.dailyIncomeTrend,
    required this.dailyExpenseTrend,
    required this.dailySavingsTrend,
    required this.dailySubscriptionTrend,
    required this.isTrendExpandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(context.l10n.dailyTrend, style: AppTextStyles.heading3),
            Container(
              margin: const EdgeInsets.only(left: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: isTrendExpandedNotifier,
                builder: (context, isExpanded, child) {
                  return IconButton(
                    onPressed: () {
                      isTrendExpandedNotifier.value =
                          !isTrendExpandedNotifier.value;
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(24, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0 : -0.25,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<bool>(
          valueListenable: isTrendExpandedNotifier,
          builder: (context, isExpanded, child) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.md,
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
                          majorGridLines: const MajorGridLines(width: 0),
                          interval: 5,
                          minimum: 1,
                          maximum: dailyIncomeTrend.length.toDouble(),
                          labelStyle: AppTextStyles.bodySmall,
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(
                            width: 1,
                            dashArray: [5, 5],
                          ),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: AppTextStyles.bodySmall,
                          numberFormat: NumberFormat.compactCurrency(
                            symbol: NumberFormat.currency(
                              name: context
                                  .read<SettingsBloc>()
                                  .state
                                  .model
                                  .defaultCurrency,
                            ).currencySymbol,
                            decimalDigits: 0,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: '',
                          canShowMarker: true,
                          format: '${context.l10n.day} point.x: point.y',
                          duration: 1000,
                          textStyle: AppTextStyles.bodyMedium,
                          color: AppColors.cardBackground,
                          borderColor: AppColors.textPrimary,
                          borderWidth: 1,
                        ),
                        series: <CartesianSeries<double, int>>[
                          LineSeries<double, int>(
                            name: context.l10n.income,
                            dataSource: dailyIncomeTrend,
                            xValueMapper: (value, index) => index + 1,
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
                            name: context.l10n.expenses,
                            dataSource: dailyExpenseTrend,
                            xValueMapper: (value, index) => index + 1,
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
                          LineSeries<double, int>(
                            name: context.l10n.navSavings,
                            dataSource: dailySavingsTrend,
                            xValueMapper: (value, index) => index + 1,
                            yValueMapper: (value, _) => value,
                            color: AppColors.savings,
                            width: 2,
                            markerSettings: const MarkerSettings(
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              width: 6,
                              height: 6,
                              color: Colors.white,
                              borderWidth: 2,
                              borderColor: AppColors.savings,
                            ),
                            enableTooltip: true,
                          ),
                          LineSeries<double, int>(
                            name: context.l10n.totalSubscriptions,
                            dataSource: dailySubscriptionTrend,
                            xValueMapper: (value, index) => index + 1,
                            yValueMapper: (value, _) => value,
                            color: AppColors.subscription,
                            width: 2,
                            markerSettings: const MarkerSettings(
                              isVisible: false,
                              shape: DataMarkerType.circle,
                              width: 6,
                              height: 6,
                              color: Colors.white,
                              borderWidth: 2,
                              borderColor: AppColors.subscription,
                            ),
                            enableTooltip: true,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}
