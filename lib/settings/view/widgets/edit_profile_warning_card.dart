import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfileWarningCard extends StatelessWidget {
  const EditProfileWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = context.select(
      (SettingsBloc bloc) => bloc.state.model.language,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.warning, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "${l10n.redBorderMeansThatYouCantChange}\n${l10n.thisFielditsOnlyForDisplay}",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: currentLanguage == 'en' ? 11.3 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
