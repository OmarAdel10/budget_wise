import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/sms_draft_card_item.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_bloc.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingSmsListView extends StatelessWidget {
  final List<SmsDraftModel> pendingDrafts;
  final ScrollController? scrollController;

  const PendingSmsListView({
    super.key,
    required this.pendingDrafts,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: pendingDrafts.length,
      itemBuilder: (context, index) {
        final draft = pendingDrafts[index];
        if (draft.transactionType == TransactionType.transfer) {
          return SmsDraftCardItem.transfer(
            draft: draft,
            onDecline: () => _onDecline(context, draft.id),
            onConfirm: (fromAccount, toAccount) =>
                _onTransferConfirm(context, draft, fromAccount, toAccount),
          );
        }
        return SmsDraftCardItem.transaction(
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
    final isMerchantRulesEnabled = context
        .read<SettingsBloc>()
        .state
        .model
        .merchantRulesEnabled;
    if (draft.extractedMerchant != null &&
        draft.extractedMerchant!.isNotEmpty &&
        isMerchantRulesEnabled) {
      context.read<MerchantCategoryLearningBloc>().add(
        MerchantCategoryLearningEventMappingSaved(
          merchantName: draft.extractedMerchant!,
          categoryId: selectedCategory.id,
          categoryTitle: selectedCategory.categoryTitle,
          transactionType: draft.transactionType,
        ),
      );
    }

    final newTransaction = TransactionModel(
      transactionAmount: draft.extractedAmount ?? 0.0,
      transactionCurrency: draft.extractedCurrency ?? 'EGP',
      transactionDate: draft.extractedDate ?? DateTime.now(),
      description: draft.extractedMerchant ?? draft.sender,
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
        toastCallback: () {
          AppToast.show(
            context,
            title: context.l10n.budgetLimitExceeded,
            type: AppToastType.warning,
          );
        },
      ),
    );
  }

  void _onTransferConfirm(
    BuildContext context,
    SmsDraftModel draft,
    AccountModel fromAccount,
    AccountModel toAccount,
  ) {
    context.read<TransactionBloc>().add(
      TransactionEventCreateTransfer(
        fromAccountId: fromAccount.id,
        toAccountId: toAccount.id,
        amount: draft.extractedAmount ?? 0.0,
        fromCurrency: draft.extractedCurrency ?? fromAccount.currency,
        destinationAmount: draft.extractedAmount ?? 0.0,
        destinationCurrency: toAccount.currency,
        transactionDate: draft.extractedDate ?? DateTime.now(),
        transactionNotes: draft.body,
        fromDescription: draft.extractedMerchant ?? 'SMS transfer',
        toDescription: draft.extractedMerchant ?? 'SMS transfer',
        toastCallback: () {
          AppToast.show(
            context,
            title: context.l10n.budgetLimitExceeded,
            type: AppToastType.warning,
          );
        },
      ),
    );
    _onDecline(context, draft.id);
  }
}
