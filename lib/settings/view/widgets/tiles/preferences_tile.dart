import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/bottom_sheets/preferences_bottom_sheet.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class PreferencesTile extends StatelessWidget {
  const PreferencesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: PhosphorIconsBold.slidersHorizontal,
      title: context.l10n.preferences,
      hasPadding: true,
      showDivider: true,
      trailing: Icon(
        PhosphorIconsBold.caretRight,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PreferencesBottomSheet(),
      ),
    );
  }
}
