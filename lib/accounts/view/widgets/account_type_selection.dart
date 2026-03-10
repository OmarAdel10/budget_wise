import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_type_tile.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountTypeSelection extends StatelessWidget {
  const AccountTypeSelection({
    super.key,
    required this.l10n,
    required this.selectedAccount,
    required this.onAccountTypeSelected,
  });

  final AppLocalizations l10n;
  final ValueNotifier<AccountType> selectedAccount;
  final ValueChanged<AccountType> onAccountTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addAccountTypeHeader,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<AccountType>(
          valueListenable: selectedAccount,
          builder: (context, type, _) {
            return Row(
              children: [
                Expanded(
                  child: AccountTypeTile(
                    label: l10n.addAccountTypeCash,
                    icon: PhosphorIcons.currencyCircleDollar(
                      PhosphorIconsStyle.regular,
                    ),
                    selected: type == AccountType.cash,
                    onTap: () => onAccountTypeSelected(AccountType.cash),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AccountTypeTile(
                    label: l10n.addAccountTypeCard,
                    icon: PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
                    selected: type == AccountType.card,
                    onTap: () => onAccountTypeSelected(AccountType.card),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
