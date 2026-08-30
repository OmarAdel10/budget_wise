import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/bottom_sheets/week_start_day_picker_bottom_sheet.dart';
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

class WeekStartDayTile extends StatelessWidget {
  const WeekStartDayTile({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDay = context.select(
      (SettingsBloc bloc) => bloc.state.model.weekStartDay,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        BottomSheetService.pageRoute(
          child: (context) => WeekStartDayPickerScreen(
            selectedDay: currentDay,
            onDaySelected: (day) {
              context.read<SettingsBloc>().add(
                SettingsEventUpdateWeekStartDay(day),
              );
            },
          ),
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsRegular.calendarDots,
        title: context.l10n.weekStartDay,
        subtitle: context.l10n.weekStartDayInfo,
        hasPadding: true,
        paddingVertical: AppSpacing.md,
        showDivider: true,
        trailing: Row(
          children: [
            Text(
              _dayName(context, currentDay),
              style: AppTextStyles.bodyMedium,
            ),
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
