import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountActionButtons extends StatelessWidget {
  final String accountId;

  const AccountActionButtons({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: ElevatedButton(
          onPressed: () {
            // Use context.read to get the latest account model for navigation
            final account = context
                .read<AccountBloc>()
                .state
                .accountsList
                .firstWhere((acc) => acc.id == accountId);
            Navigator.of(
              context,
            ).pushNamed(EditAccountScreen.routeName, arguments: account);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.pencilSimple,
                color: AppColors.textInverse,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.editAccount,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
