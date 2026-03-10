import 'package:budget_wise/transaction/view/widgets/empty_pending_sms_view.dart';
import 'package:budget_wise/transaction/view/widgets/pending_sms_list_view.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingSmsTransactionsScreen extends StatelessWidget {
  static const String routeName = '/pending_sms_transactions_screen';

  const PendingSmsTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingSmsTransactionsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              buildWhen: (previous, current) =>
                  previous.pendingSmsTransactions !=
                  current.pendingSmsTransactions,
              builder: (context, transactionState) {
                final pendingDrafts = transactionState.pendingSmsTransactions;

                if (pendingDrafts.isEmpty) {
                  return const EmptyPendingSmsView();
                }

                return PendingSmsListView(pendingDrafts: pendingDrafts);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
