import 'package:budget_wise/settings/view/widgets/export_csv_tile.dart';
import 'package:budget_wise/settings/view/widgets/import_csv_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class DataImportExportCard extends StatelessWidget {
  const DataImportExportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Column(
        children: [
          ImportCsvTile(),
          ExportCsvTile(),
        ],
      ),
    );
  }
}