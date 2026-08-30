import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountDeleteCard extends StatelessWidget {
  final String accountId;

  const AccountDeleteCard({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextButton.icon(
        onPressed: () => onDelete(context),
        icon: Icon(Icons.delete_forever, color: AppColors.danger),
        label: Text(
          context.l10n.deleteAccount,
          style: AppTextStyles.button.copyWith(color: AppColors.danger),
        ),
      ),
    );
  }

  void onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteAccount, style: AppTextStyles.heading3),
        content: Text(context.l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.back,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountBloc>().add(
                AccountEventDeleteAccount(accountId: accountId),
              );
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text(
              context.l10n.deleteAccount,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
