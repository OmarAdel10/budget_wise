import 'package:budget_wise/csv_export/data/models/export_date_state.dart';
import 'package:budget_wise/csv_export/view_model/csv_bloc.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExportDatePickerSheet extends StatelessWidget {
  const ExportDatePickerSheet({super.key});

  Future<void> _selectMonth(
    BuildContext context,
    ValueNotifier<ExportDateState> notifier,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: notifier.value.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      notifier.value = notifier.value.copyWith(
        start: DateTime(picked.year, picked.month, 1),
        end: DateTime(picked.year, picked.month + 1, 0),
        isRange: false,
      );
    }
  }

  Future<void> _selectRange(
    BuildContext context,
    ValueNotifier<ExportDateState> notifier,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          DateTimeRange(start: notifier.value.start, end: notifier.value.end),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      notifier.value = notifier.value.copyWith(
        start: picked.start,
        end: picked.end,
        isRange: true,
      );
    }
  }

  Future<void> _handleExport(
    BuildContext context,
    ValueNotifier<ExportDateState> notifier,
  ) async {
    context.read<CsvBloc>().add(CsvExportRequested(
          start: notifier.value.start,
          end: notifier.value.end,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMMM yyyy');
    final rangeFormat = DateFormat('MMM dd, yyyy');

    final notifier = ValueNotifier<ExportDateState>(
      ExportDateState(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.navSettings,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          ValueListenableBuilder<ExportDateState>(
            valueListenable: notifier,
            builder: (context, state, _) {
              return Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      title: 'Select Month',
                      value: state.isRange ? '-' : dateFormat.format(state.start),
                      icon: PhosphorIconsRegular.calendar,
                      isSelected: !state.isRange,
                      onTap: () => _selectMonth(context, notifier),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SelectionCard(
                      title: 'Custom Range',
                      value: state.isRange
                          ? '${rangeFormat.format(state.start)} - ${rangeFormat.format(state.end)}'
                          : '-',
                      icon: PhosphorIconsRegular.calendarPlus,
                      isSelected: state.isRange,
                      onTap: () => _selectRange(context, notifier),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),
          CustomButton(
            text: 'Export to CSV',
            onPressed: () => _handleExport(context, notifier),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withAlpha(25)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
