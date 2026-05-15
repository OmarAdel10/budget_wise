import 'package:budget_wise/settings/view/widgets/bank_margin_tile.dart';
import 'package:budget_wise/settings/view/widgets/currency_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/language_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/stt_mode_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class PreferencesTileContent extends StatelessWidget {
  const PreferencesTileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SttModeTile(),
          const LanguageSettingsTile(),
          const CurrencySettingsTile(),
          const BankMarginTile(),
        ],
      ),
    );
  }
}
