import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
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

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            minWidth: MediaQuery.sizeOf(context).width * 0.8,
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.language, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.preferences, // Or we could add selectLanguage key
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          elevation: 30,
          backgroundColor: AppColors.primaryBackground,
          alignment: Alignment.center,
          content: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Divider(color: AppColors.borderColor),
                GestureDetector(
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      SettingsEventLanguageChange('en'),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.english, style: AppTextStyles.bodyMedium),
                ),
                const Divider(color: AppColors.borderColor),
                GestureDetector(
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      SettingsEventLanguageChange('ar'),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.arabic, style: AppTextStyles.bodyMedium),
                ),
                const Divider(color: AppColors.borderColor),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsRegular.globe,
        title: l10n.language,
        showDivider: true,
        hasPadding: true,
        paddingVertical: AppSpacing.md,
        trailing: Row(
          children: [
            Text(
              currentLanguage == 'en' ? l10n.english : l10n.arabic,
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
