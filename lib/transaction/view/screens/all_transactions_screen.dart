import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/widgets/month_selector.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_summary_header.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';

class AllTransactionsScreen extends StatelessWidget {
  static const String routeName = '/all-transactions';
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final isNavFromAccount = args?['isNavFromAccount'] as bool? ?? false;
    final accountModel = args?['accountModel'] as AccountModel?;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<HomeBloc>().add(
            const HomeEventChangeAccountFilter(null),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isNavFromAccount
                ? '${l10n.transactionHistory} ${l10n.ofWord} ${accountModel?.title}'
                : l10n.transactionHistory,
            style: AppTextStyles.heading3,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final currencySymbol = NumberFormat.currency(
              name: context.read<SettingsBloc>().state.model.defaultCurrency,
            ).currencySymbol;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: MonthSelector(
                    selectedMonth: state.model.currentMonth,
                    onPrevious: () => context.read<HomeBloc>().add(
                      HomeEventChangeMonth(
                        DateTime(
                          state.model.currentMonth.year,
                          state.model.currentMonth.month - 1,
                        ),
                      ),
                    ),
                    onNext: () => context.read<HomeBloc>().add(
                      HomeEventChangeMonth(
                        DateTime(
                          state.model.currentMonth.year,
                          state.model.currentMonth.month + 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: TransactionSummaryHeader(
                      income: state.model.totalIncome,
                      expenses: state.model.totalExpenses,
                      currencySymbol: currencySymbol,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: TransactionListView.sliver(
                    transactions: state.model.transactions,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
