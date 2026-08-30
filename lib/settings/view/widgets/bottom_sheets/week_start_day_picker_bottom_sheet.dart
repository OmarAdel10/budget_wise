import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WeekStartDayPickerScreen extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const WeekStartDayPickerScreen({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  String _dayName(BuildContext context, int day) {
    switch (day) {
      case 1:
        return context.l10n.saturday;
      case 2:
        return context.l10n.sunday;
      case 3:
        return context.l10n.monday;
      case 4:
        return context.l10n.tuesday;
      case 5:
        return context.l10n.wednesday;
      case 6:
        return context.l10n.thursday;
      case 7:
        return context.l10n.friday;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = [1, 2, 3, 4, 5, 6, 7];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BottomSheetService.header(
                title: context.l10n.weekStartDay,
                onTap: () => Navigator.of(context).pop(),
                hasDrag: false,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.weekStartDayInfo,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: days.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isSelected = day == selectedDay;
                    return _DayRow(
                      dayName: _dayName(context, day),
                      isSelected: isSelected,
                      onTap: () {
                        onDaySelected(day);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String dayName;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayRow({
    required this.dayName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isSelected
              ? Border.all(color: AppColors.primaryAccent, width: 2)
              : Border.all(color: AppColors.textSecondary, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dayName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                PhosphorIconsBold.check,
                color: AppColors.primaryAccent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
