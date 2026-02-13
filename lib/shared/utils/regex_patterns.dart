class RegexPatterns {
  static final RegExp lastFourDigitNumberExtraction = RegExp(
    r'(?:no\.|num|ending in|ending with|\*\*|رقم|بـ|المنتهية بـ)\s*[*X]*(\d{4})',
    caseSensitive: false,
    unicode: true,
  );

  // static final RegExp merchantExtraction = RegExp(
  //   r'(?:at|to|with|from|عند|إلى|من|لدى)\s+(.+?)(?=\s+(?:on|date|amount|value|يوم|بتاريخ|بمبلغ|رقم|الساعة|$))',
  //   caseSensitive: false,
  //   unicode: true,
  // );
  static final RegExp merchantExtraction = RegExp(
    r'(?:at|to|with|from|عند|لدى|إلى|من)\s+([^0-9\r\n]+?)(?=\s|$)',
    caseSensitive: false,
    unicode: true,
  );

  //* Currency Map based on AccountConstants and common variations
  static final Map<String, String> currencyMap = {
    r'EGP|LE|L\.E\.?|جم|ج\.م|Eg Pounds?': 'EGP',
    r'USD|\$|Dollars?|دولار': 'USD',
    r'EUR|€|Euros?|يورو': 'EUR',
    r'GBP|£|Sterling|إسترليني': 'GBP',
    r'SAR|SR|Saudi Riyal|ر\.س|ريال': 'SAR',
    r'AED|Dhs?|Dirhams?|د\.إ|درهم': 'AED',
    r'KWD|KD|Dinars?|د\.ك|دينار': 'KWD',
  };

  static String get _currencyPattern => currencyMap.keys.join('|');

  static final RegExp amountWithCurrencyRegex = RegExp(
    r'(?:(' +
        _currencyPattern +
        r')\s*(\d+(?:,\d{3})*(?:\.\d+)?))|' // Group 1: Currency, Group 2: Amount
            r'(?:(\d+(?:,\d{3})*(?:\.\d+)?)\s*(' +
        _currencyPattern +
        r'))', // Group 3: Amount, Group 4: Currency
    caseSensitive: false,
    unicode: true,
  );

  //* Matches dates like 10-18, 13/10, 2023-10-18, 18/10/2023
  static final RegExp dateRegex = RegExp(
    r"(\d{1,4}[-/]\d{1,2}(?:[-/]\d{1,4})?)",
    caseSensitive: false,
    unicode: true,
  );

  //* Transaction Type Keywords
  // static const List<String> expenseKeywords = [
  //   'purchase',
  //   'debited',
  //   'transfer from',
  //   'payment',
  //   'withdrawal',
  //   'spent',
  //   'خصم',
  //   'شراء',
  //   'تحويل من',
  //   'سحب',
  //   'تنفيذ تحويل',
  //   'مدفوعات',
  // ];

  static const List<String> incomeKeywords = [
    'deposit',
    'credited',
    'transfer to',
    'refund',
    'received',
    'إضافة',
    'تحويل لـ',
    'إيداع',
    'استرداد',
    'تحويل لحظي لبطاقتكم', // Specific for NBE incoming
  ];
}
