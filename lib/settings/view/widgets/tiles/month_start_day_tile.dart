import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

String _ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

class MonthStartDayTile extends StatelessWidget {
  final ScrollController scrollController;
  const MonthStartDayTile({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final currentDay = context.select(
      (SettingsBloc bloc) => bloc.state.model.monthStartDay,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        BottomSheetService.pageRoute(
          child: (context) {
            // final scrollController = PrimaryScrollController.of(context);
            return _MonthStartDayPickerScreen(
              scrollController: scrollController,
              selectedDay: currentDay,
              onDaySelected: (day) {
                context.read<SettingsBloc>().add(
                  SettingsEventUpdateMonthStartDay(day),
                );
              },
            );
          },
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsRegular.calendarBlank,
        title: context.l10n.monthStartDay,
        subtitle: context.l10n.monthStartDayInfo,
        hasPadding: true,
        paddingVertical: AppSpacing.md,
        showDivider: true,
        trailing: Row(
          children: [
            Text(_ordinal(currentDay), style: AppTextStyles.bodyMedium),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthStartDayPickerScreen extends StatefulWidget {
  final ScrollController scrollController;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const _MonthStartDayPickerScreen({
    required this.scrollController,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<_MonthStartDayPickerScreen> createState() =>
      _MonthStartDayPickerScreenState();
}

class _MonthStartDayPickerScreenState
    extends State<_MonthStartDayPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetService.header(title: context.l10n.monthStartDay),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Text(
                      context.l10n.monthStartDayInfo,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.35,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final day = index + 1;
                      final isSelected = day == widget.selectedDay;
                      return _DayCell(
                        day: day,
                        isSelected: isSelected,
                        onTap: () {
                          widget.onDaySelected(day);
                          Navigator.of(context).pop();
                        },
                      );
                    }, childCount: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isSelected
              ? Border.all(color: AppColors.primaryAccent, width: 2)
              : Border.all(color: AppColors.textSecondary, width: 1),
        ),
        child: Center(
          child: Text(
            _ordinal(day),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
