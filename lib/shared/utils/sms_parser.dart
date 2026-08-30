import 'package:budget_wise/category/data/constants/category_constants.dart';
import 'package:budget_wise/shared/utils/regex_patterns.dart';
import 'package:budget_wise/shared/utils/sms_text_normalizer.dart';
import 'package:budget_wise/sst/data/service/stt_constants.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';

class _SmsParseWorkspace {
  final String text;
  // a list of each character in the text
  final List<bool> _consumed;

  _SmsParseWorkspace(String body)
    // Remove white spaces
    : text = SmsTextNormalizer.normalizeWhitespace(
        // convert arabic numerals into western arabic numerals
        SmsTextNormalizer.normalizeDigits(body),
      ),
      // remove white spaces from the list, then normalize digits to western arabic numerals.
      // then get the lenght of the text and fill the list with each character index and mark it as false (aka. not extracted yet).
      _consumed = List<bool>.filled(
        SmsTextNormalizer.normalizeWhitespace(
          SmsTextNormalizer.normalizeDigits(body),
        ).length,
        false,
      );

  // when a regex found a match we call this method to call the [consumeRange] method
  void consume(Match match) => consumeRange(match.start, match.end);

  // this method looks at the start and end positions of the match and flips the corresponding false values in _consumed to true
  void consumeRange(int start, int end) {
    final safeStart = start.clamp(0, _consumed.length);
    final safeEnd = end.clamp(0, _consumed.length);
    for (var i = safeStart; i < safeEnd; i++) {
      _consumed[i] = true;
    }
  }

  // we loop through the original text and whenever a character index in the _consumed list is marked as true it the character replaces it with a space
  // then we return the result after removing the white spaces
  String get remainingText {
    final chars = text.split('');
    for (var i = 0; i < chars.length; i++) {
      if (_consumed[i]) chars[i] = ' ';
    }
    return SmsTextNormalizer.normalizeWhitespace(chars.join());
  }
}

class _TransferInfo {
  final String? source;
  final String? destination;
  final SmsTransferDirection direction;
  const _TransferInfo({this.source, this.destination, required this.direction});
}

class SmsParser {
  SmsDraftModel? parseSms({
    required String sender,
    required String body,
    required List<String> potentialSenderIds,
    DateTime? messageDate,
  }) {
    final isRelevantSender = potentialSenderIds.any(
      (id) =>
          sender.toUpperCase().contains(id.toUpperCase()) ||
          id.toUpperCase().contains(sender.toUpperCase()),
    );

    final workspace = _SmsParseWorkspace(body);
    final cleanBody = workspace.text;
    final searchableBody = SmsTextNormalizer.normalizeForSearch(cleanBody);

    if (cleanBody.contains(RegexPatterns.securityCodeConfirmation)) return null;

    final amountMatch = RegexPatterns.amountWithCurrencyRegex.firstMatch(
      cleanBody,
    );
    if (amountMatch == null && !isRelevantSender) return null;
    if (amountMatch == null) return null;

    final rawCurrency = amountMatch.group(1) ?? amountMatch.group(4) ?? 'EGP';
    final rawAmount = amountMatch.group(2) ?? amountMatch.group(3) ?? '0';
    final amount =
        double.tryParse(SmsTextNormalizer.normalizeNumber(rawAmount)) ?? 0.0;
    if (amount == 0.0) return null;
    workspace.consume(amountMatch);

    final currency = _normalizeCurrency(rawCurrency);
    final transferInfo = _extractTransferInfo(
      cleanBody,
      searchableBody,
      workspace,
    );

    String? cardLastFour;
    String? transferSourceLastFour;
    String? transferDestinationLastFour;
    var transferDirection = SmsTransferDirection.unknown;

    if (transferInfo != null) {
      transferSourceLastFour = transferInfo.source;
      transferDestinationLastFour = transferInfo.destination;
      transferDirection = transferInfo.direction;
      cardLastFour = switch (transferDirection) {
        SmsTransferDirection.outgoing => transferSourceLastFour,
        SmsTransferDirection.incoming => transferDestinationLastFour,
        SmsTransferDirection.unknown => null,
      };
    } else {
      final cardMatch = RegexPatterns.lastFourDigitNumberExtraction.firstMatch(
        cleanBody,
      );
      if (cardMatch != null) {
        cardLastFour = cardMatch.group(1);
        workspace.consume(cardMatch);
      }
    }

    var type = _detectTransactionType(searchableBody);
    // if (transferInfo != null) {
    //   type = TransactionType.transfer;
    // }
    final suggestedCategoryTitle = _suggestCategoryTitle(searchableBody, type);

    var timestamp = messageDate ?? DateTime.now();
    final dateMatch = RegexPatterns.dateRegex.firstMatch(cleanBody);
    if (dateMatch != null) {
      final dateStr = dateMatch.group(0)!; // Full Match
      timestamp = _parseDate(dateStr, timestamp) ?? timestamp;
      workspace.consume(dateMatch);
    }

    final timeMatch = RegexPatterns.timeRegex.firstMatch(cleanBody);
    if (timeMatch != null) {
      final matchStr = timeMatch.group(0)!; // Full Match
      final timeParts = matchStr.split(':');

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      timestamp = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
        hour,
        minute,
      );
      workspace.consume(timeMatch);
    }

    final merchant = _extractMerchant(workspace.remainingText, type);

    return SmsDraftModel(
      sender: sender,
      body: body,
      extractedMerchant: merchant,
      extractedAmount: amount,
      extractedCurrency: currency,
      extractedDate: timestamp,
      extractedCardLastFour: cardLastFour,
      transactionType: type,
      suggestedCategoryTitle: suggestedCategoryTitle,
      transferSourceLastFour: transferSourceLastFour,
      transferDestinationLastFour: transferDestinationLastFour,
      transferDirection: transferDirection,
      matchedAccountId: null,
      timestamp: messageDate ?? DateTime.now(),
    );
  }

  String _normalizeCurrency(String rawSymbol) {
    for (final entry in RegexPatterns.currencyMap.entries) {
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

  TransactionType _detectTransactionType(String searchableBody) {
    // Check for income keywords first
    if (_containsAny(searchableBody, [
      ...RegexPatterns.incomeKeywords,
      ...SttConstants.incomeWords,
      ...CategoryConstants.incomeCategories.values.expand(
        (category) => category.keywords,
      ),
    ])) {
      return TransactionType.income;
    }

    // 2. Expense keywords (NEW - before transfer!)
    if (_containsAny(searchableBody, [
      ...RegexPatterns.expenseKeywords,
      ...SttConstants.expensesWords, // already exists, currently unused here
      ...CategoryConstants.expenseCategories.values.expand((c) => c.keywords),
    ])) {
      return TransactionType.expense;
    }

    // Then check for transfer keywords
    if (_containsAny(searchableBody, [
      ...SttConstants.transferWords,
      ...CategoryConstants.transferCategories.values.expand(
        (category) => category.keywords,
      ),
    ])) {
      return TransactionType.transfer;
    }

    // If neither income nor transfer keywords are found, default to expense
    return TransactionType.expense;
  }

  String? _suggestCategoryTitle(String searchableBody, TransactionType type) {
    final categories = switch (type) {
      TransactionType.income => CategoryConstants.incomeCategories,
      TransactionType.expense => CategoryConstants.expenseCategories,
      TransactionType.transfer => CategoryConstants.transferCategories,
    };

    // (Confidence Resolution) scoring map: key = category name, value = score
    final Map<String, int> scores = {};
    String? bestCategory;
    var bestKeywordScore = 0;
    final int mininumKeywordLength = 4; // threshold gate
    for (final entry in categories.entries) {
      for (final keyword in entry.value.keywords) {
        final normalizedKeyword = SmsTextNormalizer.normalizeForSearch(keyword);

        // applying the threshold
        if (normalizedKeyword.length < mininumKeywordLength) continue;

        if (normalizedKeyword.isNotEmpty &&
            searchableBody.contains(normalizedKeyword)) {
          final score = normalizedKeyword.length;
          scores[entry.key] = (scores[entry.key] ?? 0) + score;
        }
      }
    }

    for (final entry in scores.entries) {
      if (entry.value > bestKeywordScore) {
        bestKeywordScore = entry.value;
        bestCategory = entry.key;
      }
    }
    return bestCategory;
  }

  bool _containsAny(String normalizedBody, Iterable<String> keywords) {
    for (final keyword in keywords) {
      final normalizedKeyword = SmsTextNormalizer.normalizeForSearch(keyword);
      if (normalizedKeyword.isNotEmpty &&
          normalizedBody.contains(normalizedKeyword)) {
        return true;
      }
    }
    return false;
  }

  String? _extractMerchant(String remainingText, TransactionType type) {
    String delimters = r'merchant|pos|at|with|لدى|لدي';
    if (type == TransactionType.expense) {
      delimters += r'|عند|فى|في|إلى|الي|الى';
    } else if (type == TransactionType.income) {
      delimters += r'|من';
    } else if (type == TransactionType.transfer) {
      delimters += r'|إلى|الي|الى';
    }
    final delimiterPattern = RegExp(
      '(?:$delimters)\\s+(.+)',
      caseSensitive: false,
      unicode: true,
    );
    final delimiterMatch = delimiterPattern.firstMatch(remainingText);
    final candidate = delimiterMatch?.group(1) ?? remainingText;
    return _cleanupMerchantCandidate(candidate);
  }

  _TransferInfo? _extractTransferInfo(
    String cleanBody,
    String searchableBody,
    _SmsParseWorkspace workspace,
  ) {
    const accounts =
        r'حسابكم|حسابك|حسابي|حساب|بطاقتكم|بطاقتك|بطاقتي|بطاقة|رقم|account|card';
    const dirFrom = r'من|from';
    const dirTo = r'الى|الي|إلى|to';
    final transferKeywords = SttConstants.transferWords.join('|');

    final patternA = RegExp(
      '(?:$transferKeywords)?.*?(?:$dirFrom)\\s*(?:$accounts)?\\s*'
      '(?:رقم)?\\s*(\\d{4}).{0,80}?(?:$dirTo)\\s*(?:$accounts)?\\s*'
      '(?:رقم)?\\s*(\\d{4})',
      caseSensitive: false,
      unicode: true,
    );
    final matchA = patternA.firstMatch(cleanBody);
    if (matchA != null) {
      workspace.consume(matchA);
      return _TransferInfo(
        source: matchA.group(1),
        destination: matchA.group(2),
        direction: SmsTransferDirection.outgoing,
      );
    }

    final patternB = RegExp(
      '(?:$transferKeywords)?.*?(?:$dirTo)\\s*(?:$accounts)?\\s*'
      '(?:رقم)?\\s*(\\d{4}).{0,80}?(?:$dirFrom)\\s*(?:$accounts)?\\s*'
      '(?:رقم)?\\s*(\\d{4})',
      caseSensitive: false,
      unicode: true,
    );
    final matchB = patternB.firstMatch(cleanBody);
    if (matchB != null) {
      workspace.consume(matchB);
      return _TransferInfo(
        source: matchB.group(2),
        destination: matchB.group(1),
        direction: SmsTransferDirection.incoming,
      );
    }

    const incomingKw =
        r'ايداع|credited|deposit|اضافة|refund|received|تحويل لحظي|تحويل ل';
    final hasIncomingKw = RegExp(
      incomingKw,
      caseSensitive: false,
      unicode: true,
    ).hasMatch(searchableBody);
    if (hasIncomingKw) {
      final patternC = RegExp(
        '(?:$dirTo)\\s+(?:$accounts)?\\s*(?:رقم)?\\s*(\\d{4})',
        caseSensitive: false,
        unicode: true,
      );
      final matchC = patternC.firstMatch(cleanBody);
      if (matchC != null) {
        workspace.consume(matchC);
        return _TransferInfo(
          source: null,
          destination: matchC.group(1),
          direction: SmsTransferDirection.incoming,
        );
      }
    }

    const outgoingKw = r'حولت|تحويل من|تحويل|نقلت|transfer|move_funds';
    final hasOutgoingKw = RegExp(
      outgoingKw,
      caseSensitive: false,
      unicode: true,
    ).hasMatch(searchableBody);
    if (hasOutgoingKw) {
      final patternD = RegExp(
        '(?:$dirFrom)\\s+(?:$accounts)?\\s*(?:رقم)?\\s*(\\d{4})',
        caseSensitive: false,
        unicode: true,
      );
      final matchD = patternD.firstMatch(cleanBody);
      if (matchD != null) {
        workspace.consume(matchD);
        return _TransferInfo(
          source: matchD.group(1),
          destination: null,
          direction: SmsTransferDirection.outgoing,
        );
      }
    }

    return null;
  }

  String? _cleanupMerchantCandidate(String candidate) {
    var merchant = candidate
        .split(
          RegExp(
            r'(?:الرصيد|رصيد|balance|available|متاح|المتاح|بتاريخ|تاريخ|الساعة|الساعه|ساعه|ساعة)',
            caseSensitive: false,
            unicode: true,
          ),
        )
        .first;
    merchant = merchant
        .replaceAll(
          RegExp(
            r'(?:تم|خصم|مبلغ|من|الي|الى|إلى|بطاقتك|بطاقة|حساب|رقم|egp|le|جم|جنيه|جنيها|يوم|اليوم|مرجعي|مرجعى|الدفع المقدم|المدفوعة مقدماً|مسبقة الدفع|عند)',
            caseSensitive: false,
            unicode: true,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'[*#:\-–—]+'), ' ');
    // Strip trailing date (13/06/26, 11/06, etc.)
    merchant = merchant.replaceAll(
      RegExp(r'\s+\d{1,2}[-/\.]\d{1,2}(?:[-/\.](?:\d{2}|\d{4}))?\s*$'),
      '',
    );
    // Strip trailing digits (reference numbers, etc.)
    merchant = merchant.replaceAll(RegExp(r'\s+\d[\d\s]*$'), '');
    // Strip leading all-digit sequences (merchant IDs, terminal IDs)
    merchant = merchant.replaceAll(RegExp(r'^\d+\s+'), '');
    merchant = SmsTextNormalizer.normalizeWhitespace(merchant);
    if (merchant.length < 2) return null;
    return merchant;
  }

  DateTime? _parseDate(String dateStr, DateTime messageDate) {
    try {
      final normalized = SmsTextNormalizer.normalizeDigits(
        dateStr,
      ).replaceAll(RegExp(r'[/\.]'), '-');
      final parts = normalized.split('-');
      if (parts.length < 2) return null;

      int? year = messageDate.year;
      int? month;
      int? day;

      if (parts.length >= 3) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final p2 = int.tryParse(parts[2]);

        if (p0 == null || p1 == null || p2 == null) return null;

        if (parts[0].length == 4) {
          // YYYY-MM-DD
          year = p0;
          month = p1;
          day = p2;
        } else if (parts[2].length == 4) {
          // DD-MM-YYYY
          year = p2;
          month = p1;
          day = p0;
        } else if (parts[2].length == 2) {
          // DD-MM-YY
          year = 2000 + p2;
          month = p1;
          day = p0;
        }
      }

      if (day == null && parts.length <= 2) {
        // handle 2 parts date (DD-MM or MM-DD)
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        if (p0 == null || p1 == null) return null;

        if (p0 > 12) {
          day = p0;
          month = p1;
        } else if (p1 > 12) {
          day = p1;
          month = p0;
        } else {
          // ambiguous case: default to DD-MM (standard in middle east)
          day = p0;
          month = p1;
        }
      }

      if (day == null ||
          month == null ||
          month < 1 ||
          month > 12 ||
          day < 1 ||
          day > 31) {
        return null;
      }

      final date = DateTime(year, month, day);
      return date;
    } catch (_) {
      return null;
    }
  }
}
