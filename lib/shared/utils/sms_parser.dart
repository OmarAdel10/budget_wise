import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/shared/utils/regex_patterns.dart';

class SmsParser {
  SmsDraftModel? parseSms({
    required String sender,
    required String body,
    required List<String> potentialSenderIds,
    DateTime? messageDate,
  }) {
    // 1. Filter: Check if the sender is relevant or if the body looks like a transaction
    // We strictly check potentialSenderIds to avoid parsing spam,
    // but we use a loose check (contains) because sender IDs vary (e.g., "NBE" vs "NBE-SMS").
    bool isRelevantSender = potentialSenderIds.any(
      (id) =>
          sender.toUpperCase().contains(id.toUpperCase()) ||
          id.toUpperCase().contains(sender.toUpperCase()),
    );

    // If sender doesn't match, we can optionally check if the body has strong transaction indicators.
    // For now, let's proceed if it's a relevant sender OR if we find a valid amount+currency match.
    // Ideally, we want to be permissive with the parser but strict with what we return.

    // Clean up body
    String cleanBody = body.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 2. Parse Amount & Currency
    final amountMatch = RegexPatterns.amountWithCurrencyRegex.firstMatch(
      cleanBody,
    );
    // Integrate isRelevantSender into the parsing flow:
    // Proceed if sender is relevant (isRelevantSender is true)
    // OR if an amount match is found (amountMatch is not null).
    // If NEITHER of these conditions is met, return null immediately.
    if (amountMatch == null && !isRelevantSender) {
      return null;
    }

    // If amountMatch is still null here, it means isRelevantSender MUST be true.
    // However, for a valid transaction draft, a non-zero extracted amount is required.
    // So, even with a relevant sender, if no amount is found, we cannot create a draft.
    if (amountMatch == null) {
      return null; // No amount, not a transaction
    }
    String rawCurrency = amountMatch.group(1) ?? amountMatch.group(4) ?? 'EGP';
    String rawAmount = amountMatch.group(2) ?? amountMatch.group(3) ?? '0';

    double amount = double.tryParse(rawAmount.replaceAll(',', '')) ?? 0.0;
    if (amount == 0.0) return null;

    String currency = _normalizeCurrency(rawCurrency);

    // 3. Parse Transaction Type
    TransactionType type = _detectTransactionType(cleanBody);

    // 4. Parse Card Last 4 Digits
    String? cardLastFour;
    final cardMatch = RegexPatterns.lastFourDigitNumberExtraction.firstMatch(
      cleanBody,
    );
    if (cardMatch != null) {
      cardLastFour = cardMatch.group(1);
    }

    // 5. Parse Merchant / Sender / Receiver
    String? merchant;
    final merchantMatch = RegexPatterns.merchantExtraction.firstMatch(
      cleanBody,
    );
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)?.trim();
      // Cleanup: Remove common leading/trailing punctuation if captured
      merchant = merchant?.replaceAll(RegExp(r'^[-*]+|[-*]+$'), '').trim();
    }

    // 6. Parse Date
    DateTime timestamp = messageDate ?? DateTime.now();
    final dateMatch = RegexPatterns.dateRegex.firstMatch(cleanBody);
    if (dateMatch != null) {
      String dateStr = dateMatch.group(1)!;
      timestamp = _parseDate(dateStr, timestamp) ?? timestamp;
    }

    // 7. Parse Time (Optional, but good to have)
    // Looking for HH:mm pattern
    final timeMatch = RegExp(r'(\d{2}:\d{2})').firstMatch(cleanBody);
    if (timeMatch != null) {
      final timeParts = timeMatch.group(1)!.split(':');
      timestamp = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    }

    // Return the Draft Model
    return SmsDraftModel(
      sender: sender,
      body: body,
      extractedMerchant: merchant,
      extractedAmount: amount,
      extractedCurrency: currency,
      extractedDate: timestamp,
      extractedCardLastFour: cardLastFour,
      transactionType: type,
      matchedAccountId: null,
      timestamp: messageDate ?? DateTime.now(),
    );
  }

  String _normalizeCurrency(String rawSymbol) {
    for (var entry in RegexPatterns.currencyMap.entries) {
      if (RegExp(
        entry.key,
        caseSensitive: false,
        unicode: true,
      ).hasMatch(rawSymbol)) {
        return entry.value;
      }
    }
    return 'EGP';
  }

  TransactionType _detectTransactionType(String body) {
    String lowerBody = body.toLowerCase();
    for (final keyword in RegexPatterns.incomeKeywords) {
      if (lowerBody.contains(keyword.toLowerCase())) {
        return TransactionType.income;
      }
    }
    return TransactionType.expense;
  }

  DateTime? _parseDate(String dateStr, DateTime messageDate) {
    try {
      // Normalize separators
      String normalized = dateStr.replaceAll(RegExp(r'[/]'), '-');
      List<String> parts = normalized.split('-');

      int year = messageDate.year;
      int month = messageDate.month;
      int day = messageDate.day;

      if (parts.length == 2) {
        int p1 = int.tryParse(parts[0]) ?? 0;
        int p2 = int.tryParse(parts[1]) ?? 0;

        if (p1 == 0 || p2 == 0 || p1 > 31 || p2 > 31) return null;

        // Rule 1: If one is definitely a day (> 12), use it.
        if (p1 > 12) {
          day = p1;
        } else if (p2 > 12) {
          day = p2;
        }
        // Rule 2: If one matches the received month, the other is likely the day.
        else if (p1 == messageDate.month && p2 != messageDate.month) {
          day = p2;
        } else if (p2 == messageDate.month && p1 != messageDate.month) {
          day = p1;
        }
        // Rule 3: Fallback - assume DD-MM (common in Egypt)
        else {
          day = p1;
        }
      } else if (parts.length >= 3) {
        // ... (existing logic for YYYY-MM-DD or DD-MM-YYYY)
        if (parts[0].length == 4) {
          year = int.parse(parts[0]);
          month = int.parse(parts[1]);
          day = int.parse(parts[2]);
        } else if (parts[2].length == 4) {
          day = int.parse(parts[0]);
          month = int.parse(parts[1]);
          year = int.parse(parts[2]);
        }
      }

      // Final validation of the constructed date
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}
