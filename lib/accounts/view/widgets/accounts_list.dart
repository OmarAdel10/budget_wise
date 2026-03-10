import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/widgets/asset_item.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountsList extends StatelessWidget {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AccountDetailScreen.routeName,
                      arguments: accountItem,
                    );
                  },
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
                              title: l10n.accountDeleted,
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
                          icon: PhosphorIcons.trash(PhosphorIconsStyle.bold),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                      ],
                    ),
                    child: AssetItem(
                      icon: accountItem.accountIcon,
                      title: accountItem.title,
                      subtitle: accountItem.accountType != AccountType.cash
                          ? '${accountItem.cardBankName != null ? accountItem.cardBankName?.initialChars() : ''} • ${accountItem.cardNumber != null && accountItem.cardNumber!.length >= 4 ? accountItem.cardNumber!.substring(accountItem.cardNumber!.length - 4) : '****'}'
                          : '${accountItem.accountType.name.toUpperCase()} ${l10n.account.toUpperCase()}',
                      amount:
                          '${NumberFormat.simpleCurrency(name: accountItem.currency).currencyName} ${accountItem.balance}',
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
}
