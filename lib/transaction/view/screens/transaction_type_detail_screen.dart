import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_empty_state.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_header_card.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionTypeDetailScreen extends StatelessWidget {
  static const String routeName = '/transaction-type-detail';

  const TransactionTypeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final type = args['type'];
    final l10n = AppLocalizations.of(context)!;
    final isIncome = type == 'income';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isIncome ? l10n.incomeDetails : l10n.expenseDetails,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (previous, current) =>
              previous.currencySymbol != current.currencySymbol,
          builder: (context, settingsState) {
            return BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.model.transactions != current.model.transactions ||
                  previous.model.totalIncome != current.model.totalIncome ||
                  previous.model.totalExpenses != current.model.totalExpenses,
              builder: (context, homeState) {
                final model = homeState.model;
                final transactionsList = model.transactions
                    .where(
                      (trans) =>
                          trans.type ==
                          (isIncome
                              ? TransactionType.income
                              : TransactionType.expense),
                    )
                    .toList();

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TransactionTypeHeaderCard(
                              label:
                                  "${l10n.total} ${isIncome ? l10n.income : l10n.expenses} ${DateFormat('MMMM yyyy').format(model.currentMonth)}",
                              amount:
                                  (isIncome
                                          ? model.totalIncome
                                          : model.totalExpenses)
                                      .toString(),
                              currencySymbol: settingsState.currencySymbol,
                              isIncome: isIncome,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              l10n.transactionHistory,
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: TransactionListView.sliver(
                        transactions: transactionsList,
                        emptyState: TransactionTypeEmptyState(
                          message: l10n.noTransactionsFound,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
