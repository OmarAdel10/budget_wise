import 'package:budget_wise/accounts/view/widgets/account_balance_input.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountSettingsCard extends StatelessWidget {
  final ValueNotifier<bool> lowBalanceAlertEnabledNotifier;
  final TextEditingController lowBalanceAlertAmountController;

  const AccountSettingsCard({
    super.key,
    required this.lowBalanceAlertEnabledNotifier,
    required this.lowBalanceAlertAmountController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.1)),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: lowBalanceAlertEnabledNotifier,
        child: Text(l10n.alertOnLowBalance, style: AppTextStyles.bodyMedium),
        builder: (context, isEnabled, staticTitle) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: AlignmentGeometry.topCenter,
            child: Column(
              children: [
                SwitchListTile(
                  value: isEnabled,
                  onChanged: (value) {
                    lowBalanceAlertEnabledNotifier.value = value;
                  },
                  title: staticTitle!,
                  secondary: const Icon(
                    PhosphorIconsBold.bellRinging,
                    color: AppColors.textSecondary,
                  ),
                  activeThumbColor: AppColors.primaryAccent,
                  activeTrackColor: AppColors.primaryAccent.withValues(
                    alpha: 0.3,
                  ),
                  inactiveTrackColor: AppColors.inputBackground,
                ),
                if (isEnabled) ...[
                  AccountBalanceInput(
                    balanceController: lowBalanceAlertAmountController,
                    hasDecoration: false,
                    hasCurrencyField: false,
                    hasClearSuffix: true,
                    isLowBalanceField: true,
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
