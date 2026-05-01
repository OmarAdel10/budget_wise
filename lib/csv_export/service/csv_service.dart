import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as dev;

class CsvValidationException implements Exception {
  final String message;
  CsvValidationException(this.message);
  @override
  String toString() => message;
}

class CsvImportRow {
  final DateTime date;
  final String entryType; // Transaction, Subscription, Saving
  final String financialType; // Income, Expense
  final String title;
  final double amount;
  final String currency;
  final String categoryId;
  final String accountId;
  final String notes;

  CsvImportRow({
    required this.date,
    required this.entryType,
    required this.financialType,
    required this.title,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    required this.notes,
  });
}

class CsvService {
  static const List<String> expectedHeaders = [
    'Date',
    'Entry Type',
    'Financial Type',
    'Title/Name',
    'Amount',
    'Currency',
    'Category',
    'Account',
    'Notes/Details',
  ];
  static const String _billingCyclePrefix = 'Billing Cycle:';
  static const String _savingGoalPrefix = 'Saving Goal:';

  /// Generates the CSV content as a String from the provided data lists.
  String generateCsvContent({
    required List<TransactionModel> transactions,
    required List<SubscriptionModel> subscriptions,
    required List<SavingsModel> savings,
    required DateTime start,
    required DateTime end,
  }) {
    dev.log('Generating CSV content for range: $start to $end');
    List<List<String>> rows = [];

    // Header
    rows.add(expectedHeaders);

    final dateFormat = DateFormat('yyyy-MM-dd');

    // Add Transactions
    for (var tx in transactions) {
      if (tx.transactionDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          tx.transactionDate.isBefore(end.add(const Duration(days: 1)))) {
        rows.add([
          dateFormat.format(tx.transactionDate),
          'Transaction',
          tx.type == TransactionType.income ? 'Income' : 'Expense',
          tx.transactionTitle,
          tx.transactionAmount.toString(),
          tx.transactionCurrency,
          tx.categoryId,
          tx.accountId,
          tx.transactionNotes ?? '',
        ]);
      }
    }

    // Add Subscriptions
    for (var sub in subscriptions) {
      rows.add([
        dateFormat.format(sub.nextBillingDate),
        'Subscription',
        'Expense',
        sub.name,
        sub.amount.toString(),
        sub.currency,
        sub.categoryId,
        sub.accountId,
        'Billing Cycle: ${sub.billingCycle.name}',
      ]);
    }

    // Add Savings
    for (var goal in savings) {
      goal.contributionDates.forEach((dayIndex, date) {
        if (date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)))) {
          rows.add([
            dateFormat.format(date),
            'Saving',
            'Expense',
            '${goal.name} (Day $dayIndex)',
            goal.getAmountForDay(dayIndex).toString(),
            goal.currency,
            'Savings',
            goal.sourceAccountId,
            'Saving Goal: ${goal.name}',
          ]);
        }
      });
    }

    // Manual CSV generation
    final csv = rows.map((row) {
      return row.map((cell) {
        final escaped = cell.replaceAll('"', '""');
        return '"$escaped"';
      }).join(',');
    }).join('\n');

    dev.log('CSV generation complete. Rows: ${rows.length}');
    return csv;
  }

  BillingCycle parseBillingCycleFromNotes(String notes) {
    final normalized = notes.trim().toLowerCase();
    for (final cycle in BillingCycle.values) {
      if (normalized.contains(
        '$_billingCyclePrefix ${cycle.name}'.toLowerCase(),
      )) {
        return cycle;
      }
    }
    return BillingCycle.monthly;
  }

  String extractSavingGoalName(String title, String notes) {
    final normalizedNotes = notes.trim();
    if (normalizedNotes.toLowerCase().startsWith(_savingGoalPrefix.toLowerCase())) {
      return normalizedNotes.substring(_savingGoalPrefix.length).trim();
    }

    return title.replaceFirst(RegExp(r'\s*\(Day\s*\d+\)\s*$'), '').trim();
  }

  int? extractSavingDayIndex(String title) {
    final match = RegExp(r'\(Day\s*(\d+)\)\s*$').firstMatch(title);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  String stripSavingDaySuffix(String title) {
    return title.replaceFirst(RegExp(r'\s*\(Day\s*\d+\)\s*$'), '').trim();
  }

  /// Parses a CSV string into a list of CsvImportRow.
  /// Throws CsvValidationException if schema is invalid.
  List<CsvImportRow> parseCsv(String csvContent) {
    if (csvContent.trim().isEmpty) {
      throw CsvValidationException('The CSV file is empty.');
    }

    // Basic CSV splitting (handling quotes simply)
    final lines = csvContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      throw CsvValidationException('No data found in the CSV file.');
    }

    // 1. Validate Headers
    final headerRow = _splitCsvLine(lines[0]);
    if (headerRow.length < expectedHeaders.length) {
      throw CsvValidationException('Invalid CSV format: Missing columns.');
    }

    for (int i = 0; i < expectedHeaders.length; i++) {
      if (headerRow[i].toLowerCase() != expectedHeaders[i].toLowerCase()) {
        throw CsvValidationException(
          'Header mismatch at column ${i + 1}. Expected "${expectedHeaders[i]}" but found "${headerRow[i]}".',
        );
      }
    }

    // 2. Parse Rows
    final List<CsvImportRow> importedRows = [];
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = 1; i < lines.length; i++) {
      final cells = _splitCsvLine(lines[i]);
      if (cells.length < expectedHeaders.length) {
        dev.log('Skipping row $i: Insufficient columns');
        continue;
      }

      try {
        final date = dateFormat.parse(cells[0].trim());
        final entryType = cells[1].trim();
        final financialType = cells[2].trim();
        final title = cells[3].trim();
        final amount = double.parse(cells[4].trim().replaceAll(',', ''));
        final currency = cells[5].trim();
        final categoryId = cells[6].trim();
        final accountId = cells[7].trim();
        final notes = cells[8].trim();

        importedRows.add(CsvImportRow(
          date: date,
          entryType: entryType,
          financialType: financialType,
          title: title,
          amount: amount,
          currency: currency,
          categoryId: categoryId,
          accountId: accountId,
          notes: notes,
        ));
      } catch (e) {
        throw CsvValidationException('Error in row ${i + 1}: ${e.toString()}');
      }
    }

    return importedRows;
  }

  /// Helper to split CSV line handling basic quotes
  List<String> _splitCsvLine(String line) {
    // This is a naive CSV splitter that handles "cell,with,comma" but not nested escaped quotes well.
    // For a production app, we'd use the 'csv' package we installed earlier.
    // But since the user saw issues with it, I'll use a slightly more robust regex or logic.
    final List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentCell = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentCell.toString().trim());
        currentCell.clear();
      } else {
        currentCell.write(char);
      }
    }
    result.add(currentCell.toString().trim());
    return result;
  }

  /// Handles the file picking and saving process.
  Future<bool> exportToCsv({
    required String csvContent,
    required String fileName,
  }) async {
    try {
      dev.log('Opening file picker for fileName: $fileName');
      final bytes = utf8.encode(csvContent);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Save Location',
        fileName: fileName,
        type: FileType.any,
        bytes: bytes,
      );

      if (outputFile == null) {
        dev.log('File picker returned null (user cancelled)');
        return false;
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }

      return true;
    } catch (e, stack) {
      dev.log('Export error: $e', stackTrace: stack);
      return false;
    }
  }

  /// Handles file picking for import.
  Future<String?> pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.bytes != null) {
        return utf8.decode(file.bytes!);
      } else if (file.path != null) {
        return await File(file.path!).readAsString();
      }
      return null;
    } catch (e) {
      dev.log('File pick error: $e');
      return null;
    }
  }
}
