import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/l10n/app_localizations.dart';

class CategoryTransactionList extends StatelessWidget {
  final String categoryId;

  const CategoryTransactionList({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final transactions = context.select<HomeBloc, List<TransactionModel>>((homeBloc) {
      return homeBloc.state.model.transactions
          .where((expense) => expense.categoryId == categoryId)
          .toList();
    });

    final dummyTransaction = TransactionModel(
      type: TransactionType.expense,
      transactionTitle: 'Prototype',
      transactionAmount: 0.0,
      transactionCurrency: 'USD',
      categoryId: categoryId,
      accountId: '',
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return TransactionListView.sliver(
      transactions: transactions,
      prototypeItem: TransactionListItem(
        model: dummyTransaction,
        onDelete: null,
      ),
      emptyState: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Text(
              l10n.noRecentTransactionsFound,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
