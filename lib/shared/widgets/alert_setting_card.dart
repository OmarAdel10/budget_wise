import 'package:budget_wise/shared/widgets/balance_input_with_currency.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AlertSettingCard extends StatelessWidget {
  final ValueNotifier<bool> enabledNotifier;
  final TextEditingController alertAmountController;
  final Color backgroundColorDecoration;
  final Color textFieldBgColor;
  final String? settingTitle;
  final String? textFieldTitle;
  final String? note;

  const AlertSettingCard({
    super.key,
    required this.enabledNotifier,
    required this.alertAmountController,
    this.backgroundColorDecoration = AppColors.cardBackground,
    this.textFieldBgColor = AppColors.inputBackground,
    this.settingTitle,
    this.textFieldTitle,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColorDecoration,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.1)),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: enabledNotifier,
        child: Text(
          settingTitle ?? l10n.alertOnLowBalance,
          style: AppTextStyles.bodyMedium,
        ),
        builder: (context, isEnabled, staticTitle) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: AlignmentGeometry.topCenter,
            child: Column(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: SwitchListTile(
                    value: isEnabled,
                    onChanged: (value) {
                      enabledNotifier.value = value;
                    },
                    title: staticTitle!,
                    subtitle: note != null && note!.isNotEmpty
                        ? Text(note!, style: AppTextStyles.bodySmall)
                        : null,
                    secondary: Icon(
                      PhosphorIconsBold.bellRinging,
                      color: isEnabled
                          ? AppColors.primaryAccent
                          : AppColors.textSecondary,
                    ),
                    activeThumbColor: AppColors.primaryAccent,
                    activeTrackColor: AppColors.primaryAccent.withValues(
                      alpha: 0.3,
                    ),
                    inactiveTrackColor: AppColors.inputBackground,
                  ),
                ),
                if (isEnabled) ...[
                  BalanceInputWithCurrency(
                    balanceController: alertAmountController,
                    hasDecoration: false,
                    hasCurrencyPrefix: false,
                    hasClearSuffix: true,
                    backgroundColor: textFieldBgColor,
                    fieldCustomTitle: textFieldTitle,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
