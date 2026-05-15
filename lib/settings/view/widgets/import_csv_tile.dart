import 'package:budget_wise/csv_export/view_model/csv_bloc.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ImportCsvTile extends StatelessWidget {
  const ImportCsvTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: PhosphorIconsRegular.downloadSimple,
      title: 'Import Data',
      trailing: const Icon(
        PhosphorIconsBold.caretRight,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: () {
        context.read<CsvBloc>().add(const CsvImportRequested());
      },
      showDivider: true,
      hasPadding: true,
      paddingVertical: AppSpacing.sm,
    );
  }
}
