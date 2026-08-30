import 'dart:async';

import 'package:budget_wise/csv_export/service/csv_service.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/view_model/buckets_event.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:uuid/uuid.dart';

part 'csv_event.dart';
part 'csv_state.dart';

class CsvBloc extends Bloc<CsvEvent, CsvState> {
  final CsvService csvService;
  final TransactionBloc transactionBloc;
  final SubscriptionBloc subscriptionBloc;
  final BucketsBloc savingsBloc;

  CsvBloc({
    required this.csvService,
    required this.transactionBloc,
    required this.subscriptionBloc,
    required this.savingsBloc,
  }) : super(const CsvInitial()) {
    on<CsvExportRequested>(_onExportRequested);
    on<CsvImportRequested>(_onImportRequested);
  }

  Future<void> _onExportRequested(
    CsvExportRequested event,
    Emitter<CsvState> emit,
  ) async {
    emit(const CsvLoading('Preparing your export...'));
    try {
      final transactions = transactionBloc.state.transactionsList;
      final subscriptions = subscriptionBloc.state.subscriptions;
      final savings = savingsBloc.state.savingsList;

      final csvContent = csvService.generateCsvContent(
        transactions: transactions,
        subscriptions: subscriptions,
        savings: savings,
        start: event.start,
        end: event.end,
      );

      final fileName =
          'BudgetWise_Export.csv'; // Could be dynamic based on range

      final success = await csvService.exportToCsv(
        csvContent: csvContent,
        fileName: fileName,
      );

      if (success) {
        emit(const CsvExportSuccess());
      } else {
        emit(const CsvFailure('Export cancelled or failed.'));
      }
    } catch (e) {
      emit(CsvFailure('Export Error: ${e.toString()}'));
    }
  }

  Future<void> _onImportRequested(
    CsvImportRequested event,
    Emitter<CsvState> emit,
  ) async {
    emit(const CsvLoading('Reading CSV file...'));
    try {
      final csvContent = await csvService.pickCsvFile();
      if (csvContent == null) {
        emit(const CsvInitial()); // User cancelled
        return;
      }

      emit(const CsvLoading('Validating data...'));
      final rows = csvService.parseCsv(csvContent);

      if (rows.isEmpty) {
        emit(const CsvFailure('The CSV file has no valid data rows.'));
        return;
      }

      emit(const CsvLoading('Importing items...'));

      final now = DateTime.now();
      final userId = transactionBloc.authRepository.currentUser?.uid ?? '';
      int skippedCount = 0;

      final existingTransactionKeys = transactionBloc.state.transactionsList
          .map(_transactionImportKey)
          .toSet();
      final existingSubscriptionKeys = subscriptionBloc.state.subscriptions
          .map(_subscriptionImportKey)
          .toSet();
      final existingSavingsKeys = savingsBloc.state.savingsList
          .map(_savingsImportKey)
          .toSet();

      final transactionsToImport = <TransactionModel>[];
      final subscriptionsToImport = <SubscriptionModel>[];
      final savingsGroups = <String, _SavingsImportGroup>{};

      for (final row in rows) {
        final entryType = row.entryType.trim().toLowerCase();

        if (entryType == 'transaction') {
          final candidate = TransactionModel(
            id: const Uuid().v4(),
            userId: userId,
            description: row.title,
            transactionAmount: row.amount,
            transactionCurrency: row.currency,
            transactionDate: row.date,
            transactionNotes: row.notes,
            categoryId: row.categoryId,
            accountId: row.accountId,
            type: row.financialType.trim().toLowerCase() == 'income'
                ? TransactionType.income
                : TransactionType.expense,
            createdAt: now,
            updatedAt: now,
          );

          final key = _transactionImportKey(candidate);
          if (existingTransactionKeys.contains(key) ||
              transactionsToImport.any(
                (t) => _transactionImportKey(t) == key,
              )) {
            skippedCount++;
            continue;
          }

          transactionsToImport.add(candidate);
          existingTransactionKeys.add(key);
        } else if (entryType == 'subscription') {
          final billingCycle = csvService.parseBillingCycleFromNotes(row.notes);
          final candidate = SubscriptionModel(
            id: const Uuid().v4(),
            userId: userId,
            name: row.title,
            amount: row.amount,
            currency: row.currency,
            billingCycle: billingCycle,
            categoryId: row.categoryId,
            accountId: row.accountId,
            icon: PhosphorIconsFill.repeat,
            iconColorValue: const Color(0xFF4CAF50).toARGB32(),
            startDate: row.date,
            billingDay: row.date.day,
            nextBillingDate: row.date,
            lastPaidDate: null,
            inActive: false,
            reminderEnabled: true,
            remindBeforeDays: 1,
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          );

          final key = _subscriptionImportKey(candidate);
          if (existingSubscriptionKeys.contains(key) ||
              subscriptionsToImport.any(
                (s) => _subscriptionImportKey(s) == key,
              )) {
            skippedCount++;
            continue;
          }

          subscriptionsToImport.add(candidate);
          existingSubscriptionKeys.add(key);
        } else if (entryType == 'saving') {
          final goalName = csvService.extractSavingGoalName(
            row.title,
            row.notes,
          );
          final dayIndex =
              csvService.extractSavingDayIndex(row.title) ?? row.date.day;
          final groupKey = [
            goalName.toLowerCase(),
            row.currency.toLowerCase(),
            row.accountId.toLowerCase(),
          ].join('|');

          final existingGroup = savingsGroups[groupKey];
          if (existingGroup != null && existingGroup.containsDay(dayIndex)) {
            skippedCount++;
            continue;
          }

          final group = savingsGroups.putIfAbsent(
            groupKey,
            () => _SavingsImportGroup(
              name: goalName,
              currency: row.currency,
              sourceAccountId: row.accountId,
            ),
          );
          group.addRow(dayIndex: dayIndex, amount: row.amount, date: row.date);
        }
      }

      final savingsToImport = savingsGroups.values
          .map((group) {
            return group.toModel(
              id: const Uuid().v4(),
              userId: userId,
              now: now,
            );
          })
          .where((goal) {
            final key = _savingsImportKey(goal);
            if (existingSavingsKeys.contains(key)) {
              skippedCount++;
              return false;
            }
            return true;
          })
          .toList();

      final importedCount =
          transactionsToImport.length +
          subscriptionsToImport.length +
          savingsToImport.length;

      if (importedCount == 0) {
        if (skippedCount == 0) {
          emit(const CsvFailure('No supported records were found in the CSV.'));
        } else {
          emit(CsvImportSuccess(0, skipped: skippedCount));
        }
        return;
      }

      if (transactionsToImport.isNotEmpty) {
        final completer = Completer<void>();
        transactionBloc.add(
          TransactionEventBulkCreate(
            transactions: transactionsToImport,
            completer: completer,
          ),
        );
        await completer.future;
      }

      if (subscriptionsToImport.isNotEmpty) {
        final completer = Completer<void>();
        subscriptionBloc.add(
          SubscriptionBulkCreate(
            subscriptions: subscriptionsToImport,
            completer: completer,
          ),
        );
        await completer.future;
      }

      if (savingsToImport.isNotEmpty) {
        final completer = Completer<void>();
        savingsBloc.add(
          BucketsEventBulkCreate(goals: savingsToImport, completer: completer),
        );
        await completer.future;
      }

      emit(CsvImportSuccess(importedCount, skipped: skippedCount));
    } catch (e) {
      emit(CsvFailure(e.toString()));
    }
  }

  String _transactionImportKey(TransactionModel transaction) {
    final dateKey =
        '${transaction.transactionDate.year.toString().padLeft(4, '0')}-'
        '${transaction.transactionDate.month.toString().padLeft(2, '0')}-'
        '${transaction.transactionDate.day.toString().padLeft(2, '0')}';
    return [
      (transaction.description ?? '').toLowerCase(),
      transaction.transactionAmount.toStringAsFixed(2),
      transaction.transactionCurrency.toLowerCase(),
      transaction.categoryId.toLowerCase(),
      transaction.accountId.toLowerCase(),
      transaction.type.name,
      dateKey,
    ].join('|');
  }

  String _subscriptionImportKey(SubscriptionModel subscription) {
    final dateKey =
        '${subscription.nextBillingDate.year.toString().padLeft(4, '0')}-'
        '${subscription.nextBillingDate.month.toString().padLeft(2, '0')}-'
        '${subscription.nextBillingDate.day.toString().padLeft(2, '0')}';
    return [
      subscription.name.toLowerCase(),
      subscription.amount.toStringAsFixed(2),
      subscription.currency.toLowerCase(),
      subscription.categoryId.toLowerCase(),
      subscription.accountId.toLowerCase(),
      subscription.billingCycle.name,
      dateKey,
    ].join('|');
  }

  String _savingsImportKey(SavingGoalModel goal) {
    return [
      goal.name.toLowerCase(),
      goal.currency.toLowerCase(),
      goal.sourceAccountId.toLowerCase(),
    ].join('|');
  }
}

class _SavingsImportGroup {
  final String name;
  final String currency;
  final String sourceAccountId;
  final Map<int, double> _customAmounts = {};
  final Map<int, DateTime> _contributionDates = {};
  final List<int> _completedDays = [];

  _SavingsImportGroup({
    required this.name,
    required this.currency,
    required this.sourceAccountId,
  });

  bool containsDay(int dayIndex) => _customAmounts.containsKey(dayIndex);

  void addRow({
    required int dayIndex,
    required double amount,
    required DateTime date,
  }) {
    if (_customAmounts.containsKey(dayIndex)) {
      return;
    }

    _customAmounts[dayIndex] = amount;
    _contributionDates[dayIndex] = date;
    _completedDays.add(dayIndex);
  }

  SavingGoalModel toModel({
    required String id,
    required String userId,
    required DateTime now,
  }) {
    final totalAmount = _customAmounts.values.fold<double>(
      0.0,
      (sum, amount) => sum + amount,
    );
    final targetDate = _contributionDates.values.isEmpty
        ? now
        : _contributionDates.values.reduce((a, b) => a.isAfter(b) ? a : b);
    final targetDays = _customAmounts.keys.isEmpty
        ? 0
        : _customAmounts.keys.reduce((a, b) => a > b ? a : b);

    return SavingGoalModel(
      id: id,
      userId: userId,
      name: name,
      targetAmount: totalAmount,
      currentAmount: totalAmount,
      currency: currency,
      targetDate: targetDate,
      colorValue: const Color(0xFF4CAF50).toARGB32(),
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      completedDays: List<int>.from(_completedDays)..sort(),
      contributionDates: Map<int, DateTime>.from(_contributionDates),
      method: SavingGoalMethod.custom,
      customAmounts: Map<int, double>.from(_customAmounts),
      targetDays: targetDays,
      sourceAccountId: sourceAccountId,
    );
  }
}
