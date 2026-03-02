import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/category/data/model/category_model.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/transaction/data/model/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/draft_transaction_card_item.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingSmsListView extends StatelessWidget {
  final List<SmsDraftModel> pendingDrafts;

  const PendingSmsListView({super.key, required this.pendingDrafts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: pendingDrafts.length,
      itemBuilder: (context, index) {
        final draft = pendingDrafts[index];
        return DraftTransactionCardItem(
          draft: draft,
          onDecline: () => _onDecline(context, draft.id),
          onConfirm: (selectedAccount, selectedCategory) =>
              _onConfirm(context, draft, selectedAccount, selectedCategory),
        );
      },
    );
  }

  void _onDecline(BuildContext context, String draftId) {
    context.read<TransactionBloc>().add(
      TransactionEventDeclineSmsDraft(smsDraftId: draftId),
    );
  }

  void _onConfirm(
    BuildContext context,
    SmsDraftModel draft,
    AccountModel selectedAccount,
    CategoryModel selectedCategory,
  ) {
    final newTransaction = TransactionModel(
      transactionAmount: draft.extractedAmount ?? 0.0,
      transactionCurrency: draft.extractedCurrency ?? 'EGP',
      transactionDate: draft.extractedDate ?? DateTime.now(),
      transactionTitle: draft.extractedMerchant ?? draft.sender,
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
  }
}
