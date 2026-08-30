import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/widgets/asset_item.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountsList extends StatelessWidget {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) =>
          previous.accountsList != current.accountsList,
      builder: (context, state) {
        if (state.accountsList.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox());
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final accountItem = state.accountsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    BottomSheetService.pageRoute(
                      child: (context) => AccountDetailScreen(
                        accountId: accountItem.id,
                        initialAccount: accountItem,
                      ),
                    ),
                  ),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            final accountBloc = context.read<AccountBloc>();

                            AppToast.show(
                              context,
                              type: AppToastType.deleteWithUndo,
                              title: context.l10n.accountDeleted,
                              onCompleted: () {
                                accountBloc.add(
                                  AccountEventDeleteAccount(
                                    accountId: accountItem.id,
                                  ),
                                );
                              },
                            );
                          },
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          icon: PhosphorIconsBold.trash,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                      ],
                    ),
                    child: AssetItem(
                      icon: accountItem.accountIcon,
                      title: accountItem.title,
                      subtitle: _buildSubtitle(accountItem, context),
                      amount:
                          '${NumberFormat.currency(name: accountItem.currency).currencyName} ${accountItem.balance}',
                      isWarningEnabled:
                          (accountItem.lowBalanceAlertEnabled &&
                          accountItem.balance <=
                              accountItem.lowBalanceAlertAmount),
                    ),
                  ),
                ),
              );
            }, childCount: state.accountsList.length),
          ),
        );
      },
    );
  }

  String _buildSubtitle(AccountModel account, BuildContext context) {
    if (account.accountType == AccountType.cash) {
      return '${context.l10n.addAccountTypeCash.toUpperCase()} ${context.l10n.account.toUpperCase()}';
    } else if (account.accountType == AccountType.wallet) {
      final provider = account.walletProvider ?? '';
      final phone = account.phoneNumber ?? '';
      final last4 = phone.length >= 4
          ? phone.substring(phone.length - 4)
          : phone;
      return '${provider.initialChars()} • ****$last4';
    } else {
      final bank = account.cardBankName?.initialChars() ?? '';
      final card = account.cardNumber ?? '';
      final last4 = card.length >= 4 ? card.substring(card.length - 4) : '****';
      return '$bank • $last4';
    }
  }
}
