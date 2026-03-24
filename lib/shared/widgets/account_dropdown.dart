import 'package:auto_size_text/auto_size_text.dart';
import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class AccountDropdown extends StatelessWidget {
  final ValueNotifier<String?> selectedAccountId;
  final ValueNotifier<String?>? selectedCurrency;

  const AccountDropdown({
    super.key,
    required this.selectedAccountId,
    this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (selectedCurrency == null) {
          return _buildDropdown(context, state.accountsList, null, l10n);
        }

        return ValueListenableBuilder<String?>(
          valueListenable: selectedCurrency!,
          builder: (context, currency, child) {
            final accounts = state.accountsList
                .where((acc) => acc.currency == currency)
                .toList();
            return _buildDropdown(context, accounts, currency, l10n);
          },
        );
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    List<AccountModel> accounts,
    String? currency,
    AppLocalizations l10n,
  ) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedAccountId,
      builder: (context, accountId, _) {
        final bool isSelectionValid =
            accountId != null && accounts.any((a) => a.id == accountId);
        final String? dropdownValue = isSelectionValid ? accountId : null;

        if (!isSelectionValid && accountId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            selectedAccountId.value = null;
          });
        }

        return Container(
          height: AppConstants.textFieldAndRelatedWidgetsHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              hint: AutoSizeText(
                accounts.isNotEmpty
                    ? l10n.selectAccountLabel
                    : (currency != null
                        ? l10n.noAccountsAvailableForSelectedCurrency
                        : l10n.noAccountsAvailable),
                minFontSize: 13,
                maxLines: 1,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardBackground,
              icon: Icon(
                PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                color: AppColors.textSecondary,
              ),
              items: accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Row(
                    children: [
                      Icon(account.accountIcon, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        account.title,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedAccountId.value = newValue;
              },
            ),
          ),
        );
      },
    );
  }
}
