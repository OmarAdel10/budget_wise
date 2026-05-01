import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';

class DatePickerField extends StatelessWidget {
  final ValueNotifier<DateTime> selectedDate;
  final Color activeColor;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? label;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.activeColor,
    this.firstDate,
    this.lastDate,
    this.label,
  });

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: activeColor,
              onPrimary: AppColors.textInverse,
              surface: AppColors.secondaryBackground,
              onSurface: AppColors.textPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: activeColor,
              headerForegroundColor: AppColors.textInverse,
              backgroundColor: AppColors.secondaryBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: AppConstants.textFieldAndRelatedWidgetsHeight,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, date, _) {
                      return Text(
                        DateFormat.yMMMd().format(date),
                        style: AppTextStyles.bodyLarge,
                      );
                    },
                  ),
                ),
                Icon(
                  PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
