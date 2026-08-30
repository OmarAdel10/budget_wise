import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeRecentTransactions extends StatelessWidget {
  /// When provided, this overrides the Bloc-sourced list and disables the
  /// top-N limit. Used for displaying search results.
  final List<TransactionModel>? filteredTransactions;

  const HomeRecentTransactions({super.key, this.filteredTransactions});

  @override
  Widget build(BuildContext context) {
    // If a filtered list is provided, render it directly (search mode).
    if (filteredTransactions != null) {
      return TransactionListView(transactions: filteredTransactions!);
    }

    final transactions = context.select(
      (HomeBloc bloc) => bloc.state.model.transactions,
    );

    final transactionsCount = context.select<SettingsBloc, int>(
      (bloc) => bloc.state.model.recentTransactionDisplayedCount,
    );

    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show top N recent transactions on home, filtered by category if applied
    final recentTransactions = transactions.take(transactionsCount).toList();

    return TransactionListView(transactions: recentTransactions);
  }
}
