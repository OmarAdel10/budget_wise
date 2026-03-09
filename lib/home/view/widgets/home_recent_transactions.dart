import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/shared/widgets/multi_sliver.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeRecentTransactions extends StatelessWidget {
  const HomeRecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final transactions = context.select(
      (HomeBloc bloc) => bloc.state.model.transactions,
    );

    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final recentTransactions = transactions.take(3).toList();

    return MultiSliver(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recentTransactions,
                      style: AppTextStyles.heading3,
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const HomeEventChangeAccountFilter(null));
                        Navigator.of(
                          context,
                        ).pushNamed(AllTransactionsScreen.routeName);
                      },
                      child: Text(l10n.seeAll, style: AppTextStyles.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: TransactionListView.sliver(transactions: recentTransactions),
        ),
      ],
    );
  }
}
