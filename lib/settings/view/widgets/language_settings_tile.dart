import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LanguageSettingsTile extends StatelessWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = context.select(
      (SettingsBloc bloc) => bloc.state.model.language,
    );

    return SettingsTile(
      icon: PhosphorIconsRegular.globe,
      title: l10n.language,
      showDivider: true,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguage == 'en' ? 'en' : 'ar',
          dropdownColor: AppColors.cardBackground,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(
                l10n.english,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Text(
                l10n.arabic,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
          onChanged: (String? newLangCode) {
            if (newLangCode != null) {
              context.read<SettingsBloc>().add(
                SettingsEventLanguageChange(newLangCode),
              );
            }
          },
        ),
      ),
    );
  }
}
