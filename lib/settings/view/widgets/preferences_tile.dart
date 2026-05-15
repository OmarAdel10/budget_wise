import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart' show AppSpacing;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PreferencesTile extends StatelessWidget {
  const PreferencesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: PhosphorIconsBold.slidersHorizontal,
      title: l10n.preferences,
      hasPadding: true,
      paddingVertical: AppSpacing.md,
      trailing: Icon(
        PhosphorIconsBold.caretRight,
        color: AppColors.textSecondary,
        size: 18,
      ),
    );
  }
}
