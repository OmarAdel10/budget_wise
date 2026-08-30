abstract final class SmsTextNormalizer {
  static const Map<String, String> _digitMap = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final codePoint in input.runes) {
      final char = String.fromCharCode(codePoint);
      buffer.write(_digitMap[char] ?? char);
    }
    return buffer.toString();
  }

  static String normalizeNumber(String input) {
    var result = normalizeDigits(
      input,
    ).replaceAll('\u066c', ',').replaceAll('\u066b', '.').replaceAll(' ', '');

    final hasDot = result.contains('.');
    final commaCount = ','.allMatches(result).length;

    if (!hasDot && commaCount == 1) {
      final commaIndex = result.indexOf(',');
      final fractionLength = result.length - commaIndex - 1;
      if (fractionLength > 0 && fractionLength != 3) {
        result = result.replaceFirst(',', '.');
      }
    }

    return result.replaceAll(',', '');
  }

  /// Normalizes [input] for fuzzy text search.
  ///
  /// Applies normalization via chained [String.replaceAll] calls:
  /// 1. Arabic digit normalization (Arabic-Indic → Western)
  /// 2. Lowercasing
  /// 3. Arabic character variants (إأآ → ا, ى → ي, ة → ه, ؤ → و, ئ → ي)
  /// 4. Arabic diacritics (tashkeel) and tatweel removal
  /// 5. Latin accent stripping (àáâãäå → a, èéêë → e, etc.)
  /// 6. German ß → ss and Latin ligature expansion (æ → ae, œ → oe)
  /// 7. Fullwidth → halfwidth (Ａ → A, ０ → 0, etc.)
  /// 8. Zero-width and invisible character removal
  /// 9. Non-word, non-Arabic characters → space
  /// 10. Underscore → space
  /// 11. Whitespace collapsing and trimming
  static String normalizeForSearch(String input) {
    var result = normalizeDigits(input).toLowerCase();
    result = result
        // ── Arabic character variants ────────────────────────
        .replaceAll(RegExp('[إأآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[\u064b-\u065f\u0670]'), '')
        // ── Latin accented characters (common European) ──────
        .replaceAll(RegExp('[àáâãäå]'), 'a')
        .replaceAll(RegExp('[èéêë]'), 'e')
        .replaceAll(RegExp('[ìíîï]'), 'i')
        .replaceAll(RegExp('[òóôõöø]'), 'o')
        .replaceAll(RegExp('[ùúûü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c')
        // ── German ß & Latin ligatures ───────────────────────
        .replaceAll('ß', 'ss')
        .replaceAll('æ', 'ae')
        .replaceAll('œ', 'oe')
        // ── Zero-width & invisible characters ───────────────
        .replaceAll(RegExp(r'[\u200b\u200c\u200d\u2060\uFEFF]'), '')
        // ── Fullwidth → halfwidth (CJK fullwidth forms) ─────
        .replaceAllMapped(RegExp(r'[\uFF01-\uFF5E]'), (m) {
          return String.fromCharCode(m[0]!.codeUnitAt(0) - 0xFEE0);
        });

    // Replace non-word, non-Arabic characters with space
    result = result.replaceAll(RegExp(r'[^\w\s\u0600-\u06ff]'), ' ');
    // Convert underscore to space for better matching
    result = result.replaceAll('_', ' ');
    return normalizeWhitespace(result);
  }

  static String normalizeWhitespace(String input) =>
      input.replaceAll(RegExp(r'\s+'), ' ').trim();
}
