import 'package:budget_wise/csv_export/view/widgets/export_date_picker_sheet.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ExportCsvTile extends StatelessWidget {
  const ExportCsvTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: PhosphorIconsRegular.export,
      title: 'Export Data',
      showDivider: true,
      trailing: const Icon(
        PhosphorIconsBold.caretRight,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ExportDatePickerSheet(),
        );
      },
      hasPadding: true,
      paddingVertical: AppSpacing.sm,
    );
  }
}
