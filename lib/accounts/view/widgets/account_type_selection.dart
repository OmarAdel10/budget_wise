import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_type_tile.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';

import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountTypeSelection extends StatelessWidget {
  const AccountTypeSelection({
    super.key,
    required this.selectedAccount,
    required this.onAccountTypeSelected,
  });

  final ValueNotifier<AccountType> selectedAccount;
  final ValueChanged<AccountType> onAccountTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addAccountTypeHeader,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<AccountType>(
          valueListenable: selectedAccount,
          builder: (context, type, _) {
            return SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AccountTypeTile(
                            label: context.l10n.addAccountTypeCash,
                            icon: PhosphorIconsRegular.currencyCircleDollar,
                            selected: type == AccountType.cash,
                            onTap: () =>
                                onAccountTypeSelected(AccountType.cash),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AccountTypeTile(
                            label: context.l10n.addAccountTypeCard,
                            icon: PhosphorIconsRegular.creditCard,
                            selected: type == AccountType.card,
                            onTap: () =>
                                onAccountTypeSelected(AccountType.card),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: AccountTypeTile(
                      label: context.l10n.addAccountTypeWallet,
                      icon: PhosphorIconsRegular.deviceMobile,
                      selected: type == AccountType.wallet,
                      onTap: () => onAccountTypeSelected(AccountType.wallet),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
