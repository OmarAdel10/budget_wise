import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/accounts/view/widgets/account_balance_details_header.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_details_section.dart';
import 'package:budget_wise/accounts/view/widgets/account_wallet_details_section.dart';
import 'package:budget_wise/accounts/view/widgets/low_balance_banner.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/transaction/view/widgets/all_transactions_bottom_sheet.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountDetailScreen extends StatefulWidget {
  final String accountId;
  final AccountModel? initialAccount;
  const AccountDetailScreen({
    super.key,
    required this.accountId,
    this.initialAccount,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final args = ModalRoute.of(context)!.settings.arguments;
    // if (args is AccountModel) {
    //   _initialAccount = args;
    //   _accountId = args.id;
    // } else if (args is Map<String, dynamic>) {
    //   _accountId = args['accountId'];
    // } else {
    //   // Fallback for unexpected argument types
    //   _accountId = '';
    // }
    // Notify TransactionBloc which account is selected for optimized calculations
    if (widget.accountId.isNotEmpty) {
      context.read<TransactionBloc>().add(
        TransactionEventSelectAccount(widget.accountId),
      );
    }
  }

  @override
  void dispose() {
    // Reset selection on exit to avoid stale data in other parts of the app
    // context.read<TransactionBloc>().add(const TransactionEventSelectAccount(null));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final account = state.accountsList.firstWhere(
          (acc) => acc.id == widget.accountId,
          orElse: () => widget.initialAccount ?? AccountModel.empty(),
        );

        if (account.id.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: BottomSheetService.header(
                  title: account.title,
                  actions: [
                    IconButton(
                      icon: Icon(
                        PhosphorIconsRegular.pencil,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          BottomSheetService.pageRoute(
                            child: (context) =>
                                EditAccountScreen(account: account),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        PhosphorIconsRegular.trash,
                        color: AppColors.danger,
                      ),
                      onPressed: () {
                        context.read<AccountBloc>().add(
                          AccountEventDeleteAccount(
                            accountId: widget.accountId,
                          ),
                        );
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    //* Low Balance Alert Banner
                    if (account.lowBalanceAlertEnabled &&
                        account.balance <= account.lowBalanceAlertAmount)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: LowBalanceBanner(),
                        ),
                      ),
                    //* Hero Balance Section
                    BlocBuilder<TransactionBloc, TransactionState>(
                      buildWhen: (prev, curr) =>
                          prev.currentAccountBalance !=
                              curr.currentAccountBalance ||
                          prev.lastAccountUpdatedAt !=
                              curr.lastAccountUpdatedAt,
                      builder: (context, transState) {
                        return AccountBalanceDetailsHeader(
                          balance: transState.currentAccountBalance,
                          currency: account.currency,
                          lastUpdatedAt: transState.lastAccountUpdatedAt,
                        );
                      },
                    ),
                    //* Credit Card Section (Conditional)
                    AccountCardDetailsSection(account: account),
                    //* Mobile Wallet Section (Conditional)
                    AccountWalletDetailsSection(account: account),
                    //* Recent Transactions Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.recentActivity,
                              style: AppTextStyles.heading3,
                            ),
                            GestureDetector(
                              onTap: () async {
                                context.read<HomeBloc>().add(
                                  HomeEventChangeAccountFilter(
                                    widget.accountId,
                                  ),
                                );
                                if (!context.mounted) return;
                                await AllTransactionsBottomSheet.show(context);
                                if (!context.mounted) return;
                                context.read<HomeBloc>().add(
                                  const HomeEventChangeAccountFilter(null),
                                );
                              },
                              child: Text(
                                context.l10n.viewAll,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //* Recent Transactions List
                    BlocBuilder<TransactionBloc, TransactionState>(
                      buildWhen: (previous, current) =>
                          previous.recentTransactions !=
                          current.recentTransactions,
                      builder: (context, transState) {
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          sliver: TransactionListView.sliver(
                            transactions: transState.recentTransactions,
                          ),
                        );
                      },
                    ),
                    //* Bottom Spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl * 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
