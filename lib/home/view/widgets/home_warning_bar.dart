import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeWarningBar extends StatelessWidget {
  const HomeWarningBar({super.key});

  @override
  Widget build(BuildContext context) {
    final shouldShowWarning = context.select((HomeBloc bloc) {
      final state = bloc.state;
      return state.model.totalExpenses > state.model.totalIncome;
    });

    if (!shouldShowWarning) {
      return const SizedBox.shrink();
    }

    final language = context.select(
      (SettingsBloc bloc) => bloc.state.model.language,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.warning, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.yourExpensesExceedYourIncome,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: language == 'en' ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
