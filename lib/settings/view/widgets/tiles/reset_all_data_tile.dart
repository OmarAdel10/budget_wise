import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ResetAllDataTile extends StatelessWidget {
  const ResetAllDataTile({super.key});

  @override
  Widget build(BuildContext context) {

    void resetAll() {
      context.read<TransactionBloc>().clear();
      context.read<CategoryBloc>().clear();
      context.read<AccountBloc>().clear();
      context.read<BucketsBloc>().clear();
      context.read<SubscriptionBloc>().clear();
      context.read<SettingsBloc>().clear();
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(MainScreen.routeName);
    }

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
                Text(context.l10n.startFresh, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.resetDataWarning,
                  textAlign: TextAlign.center,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: AppColors.borderColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel, style: AppTextStyles.bodyMedium),
                    ),
                    const SizedBox(
                      height: 40,
                      child: VerticalDivider(color: AppColors.borderColor),
                    ),
                    GestureDetector(
                      onTap: () => resetAll,
                      child: Text(
                        context.l10n.continueAction,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsBold.arrowClockwise,
        iconColor: AppColors.danger,
        title: context.l10n.resetAllData,
        titleColor: AppColors.danger,
        trailing: const Icon(
          PhosphorIconsBold.caretRight,
          color: AppColors.danger,
          size: 18,
        ),
      ),
    );
  }
}
