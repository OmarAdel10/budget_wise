import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_action_buttons.dart';
import 'package:budget_wise/accounts/view/widgets/account_balance_details_header.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_details_section.dart';
import 'package:budget_wise/accounts/view/widgets/low_balance_banner.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDetailScreen extends StatefulWidget {
  static const String routeName = '/accountDetail';
  const AccountDetailScreen({super.key});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late String _accountId;
  AccountModel? _initialAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is AccountModel) {
      _initialAccount = args;
      _accountId = args.id;
    } else if (args is Map<String, dynamic>) {
      _accountId = args['accountId'];
    } else {
      // Fallback for unexpected argument types
      _accountId = '';
    }
    // Notify TransactionBloc which account is selected for optimized calculations
    if (_accountId.isNotEmpty) {
      context
          .read<TransactionBloc>()
          .add(TransactionEventSelectAccount(_accountId));
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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final account = state.accountsList.firstWhere(
          (acc) => acc.id == _accountId,
          orElse: () => _initialAccount ?? AccountModel.empty(),
        );

        if (account.id.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(account.title, style: AppTextStyles.heading3),
            actions: [
              IconButton(
                icon: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: AppColors.danger,
                ),
                onPressed: () {
                  context.read<AccountBloc>().add(
                    AccountEventDeleteAccount(accountId: _accountId),
                  );
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: CustomScrollView(
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
                    prev.currentAccountBalance != curr.currentAccountBalance ||
                    prev.lastAccountUpdatedAt != curr.lastAccountUpdatedAt,
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
              //* Edit Account Button
              AccountActionButtons(accountId: _accountId),
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
                        l10n.recentTransactions,
                        style: AppTextStyles.heading3,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<HomeBloc>().add(
                            HomeEventChangeAccountFilter(_accountId),
                          );
                          Navigator.of(context).pushNamed(
                            AllTransactionsScreen.routeName,
                            arguments: {
                              'isNavFromAccount': true,
                              'accountModel': account,
                            },
                          );
                        },
                        child: Text(
                          l10n.viewAll,
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
                    previous.recentTransactions != current.recentTransactions,
                builder: (context, transState) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: TransactionListView.sliver(
                      transactions: transState.recentTransactions,
                      hasBackgroundColor: false,
                      emptyState: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Text(
                            l10n.noRecentTransactionsFound,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
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
        );
      },
    );
  }
}

