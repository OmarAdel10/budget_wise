import 'package:budget_wise/transaction/data/models/sms_draft_model.dart'; // New import
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class TransactionEventCreateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  final double? convertedAmount;

  const TransactionEventCreateTransaction(
    this.transaction, {
    this.convertedAmount,
  });

  @override
  List<Object?> get props => [transaction, convertedAmount];
}

class TransactionEventUpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  final double? convertedAmount;

  const TransactionEventUpdateTransaction(
    this.transaction, {
    this.convertedAmount,
  });

  @override
  List<Object?> get props => [transaction, convertedAmount];
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
  final String
  smsDraftId; // Assuming SmsDraftModel will have an ID or use index
  final TransactionModel transaction; // The confirmed transaction

  const TransactionEventConfirmSmsDraft({
    required this.smsDraftId,
    required this.transaction,
  });

  @override
  List<Object?> get props => [smsDraftId, transaction];
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
