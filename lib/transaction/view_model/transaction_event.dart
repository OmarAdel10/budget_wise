import 'dart:ui';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'dart:async';

import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class TransactionEventCreateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  final double? convertedAmount;
  final bool skipBalanceUpdate;
  final VoidCallback toastCallback;

  const TransactionEventCreateTransaction(
    this.transaction, {
    this.convertedAmount,
    this.skipBalanceUpdate = false,
    required this.toastCallback,
  });

  @override
  List<Object?> get props => [
    transaction,
    convertedAmount,
    skipBalanceUpdate,
    toastCallback,
  ];
}

class TransactionEventCreateTransfer extends TransactionEvent {
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final String fromCurrency;
  final double destinationAmount;
  final String destinationCurrency;
  final DateTime transactionDate;
  final String? transactionNotes;
  final String fromDescription;
  final String toDescription;
  final String? categoryId;
  final VoidCallback toastCallback;

  const TransactionEventCreateTransfer({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.fromCurrency,
    required this.destinationAmount,
    required this.destinationCurrency,
    required this.transactionDate,
    this.transactionNotes,
    required this.fromDescription,
    required this.toDescription,
    this.categoryId,
    required this.toastCallback,
  });

  @override
  List<Object?> get props => [
    fromAccountId,
    toAccountId,
    amount,
    fromCurrency,
    destinationAmount,
    destinationCurrency,
    transactionDate,
    transactionNotes,
    fromDescription,
    toDescription,
    categoryId,
    toastCallback,
  ];
}

class TransactionEventUpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  final double? convertedAmount;
  final VoidCallback toastCallback;

  const TransactionEventUpdateTransaction(
    this.transaction, {
    this.convertedAmount,
    required this.toastCallback,
  });

  @override
  List<Object?> get props => [transaction, convertedAmount, toastCallback];
}

class TransactionEventMarkSynced extends TransactionEvent {
  final String transactionId;
  const TransactionEventMarkSynced({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class TransactionEventSyncUnsynced extends TransactionEvent {
  const TransactionEventSyncUnsynced();

  @override
  List<Object?> get props => [];
}

class TransactionEventFetchAll extends TransactionEvent {
  const TransactionEventFetchAll();

  @override
  List<Object?> get props => [];
}

class TransactionEventDeleteTransaction extends TransactionEvent {
  final String transactionId;

  const TransactionEventDeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class TransactionEventSyncPendingOnLogin extends TransactionEvent {
  const TransactionEventSyncPendingOnLogin();

  @override
  List<Object?> get props => [];
}

class TransactionEventCheckAndSyncPending extends TransactionEvent {
  const TransactionEventCheckAndSyncPending();

  @override
  List<Object?> get props => [];
}

class TransactionEventAddSmsDraft extends TransactionEvent {
  final SmsDraftModel smsDraft;

  const TransactionEventAddSmsDraft({required this.smsDraft});

  @override
  List<Object?> get props => [smsDraft];
}

class TransactionEventConfirmSmsDraft extends TransactionEvent {
  final String smsDraftId;
  final TransactionModel transaction;
  final VoidCallback toastCallback;

  const TransactionEventConfirmSmsDraft({
    required this.smsDraftId,
    required this.transaction,
    required this.toastCallback,
  });

  @override
  List<Object?> get props => [smsDraftId, transaction, toastCallback];
}

class TransactionEventDeclineSmsDraft extends TransactionEvent {
  final String smsDraftId;

  const TransactionEventDeclineSmsDraft({required this.smsDraftId});

  @override
  List<Object?> get props => [smsDraftId];
}

class TransactionEventUpdateSmsDraft extends TransactionEvent {
  final SmsDraftModel updatedDraft;

  const TransactionEventUpdateSmsDraft({required this.updatedDraft});

  @override
  List<Object?> get props => [updatedDraft];
}

class TransactionEventLoadBackgroundDrafts extends TransactionEvent {
  const TransactionEventLoadBackgroundDrafts();

  @override
  List<Object?> get props => [];
}

class TransactionEventSelectAccount extends TransactionEvent {
  final String? accountId;

  const TransactionEventSelectAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class TransactionEventBulkCreate extends TransactionEvent {
  final List<TransactionModel> transactions;
  final Completer<void>? completer;

  const TransactionEventBulkCreate({
    required this.transactions,
    this.completer,
  });

  @override
  List<Object?> get props => [transactions];
}
