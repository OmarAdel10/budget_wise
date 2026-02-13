import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/widgets/draft_transaction_card_item.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_state.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingSmsTransactionsScreen extends StatefulWidget {
  static const String routeName = '/pending_sms_transactions_screen';

  const PendingSmsTransactionsScreen({super.key});

  @override
  State<PendingSmsTransactionsScreen> createState() =>
      _PendingSmsTransactionsScreenState();
}

class _PendingSmsTransactionsScreenState
    extends State<PendingSmsTransactionsScreen> {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              final pendingDrafts = transactionState.pendingSmsTransactions;

              if (pendingDrafts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noPendingSmsTransactions,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: pendingDrafts.length,
                  itemBuilder: (context, index) {
                    final draft = pendingDrafts[index];
                    return DraftTransactionCardItem(
                      draft: draft,
                      onDecline: () {
                        context.read<TransactionBloc>().add(
                          TransactionEventDeclineSmsDraft(smsDraftId: draft.id),
                        );
                      },
                      onConfirm: (selectedAccount, selectedCategory) {
                        final newTransaction = TransactionModel(
                          transactionAmount: draft.extractedAmount ?? 0.0,
                          transactionDate:
                              draft.extractedDate ?? DateTime.now(),
                          transactionTitle:
                              draft.extractedMerchant ?? draft.sender,
                          transactionNotes: draft.body,
                          type: draft.transactionType,
                          accountId: selectedAccount.id,
                          categoryId: selectedCategory.id,
                          isSynced: false,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        context.read<TransactionBloc>().add(
                          TransactionEventConfirmSmsDraft(
                            smsDraftId: draft.id,
                            transaction: newTransaction,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
