class RegexPatterns {
  // static final RegExp instapayPattern = RegExp(
  //   r'(?:تحويل لحظي|)',
  //   caseSensitive: false,
  //   unicode: true,
  // );

  static final RegExp securityCodeConfirmation = RegExp(
    r'(?:OTP|PIN|CODE|VERIFICATION|CONFIRMATION|AUTHENTICATION|SECURITY|VALIDATION|الكود|كود|السري|السرى|سري|سرى|عدم|مشاركته|مشاركتة|شخص)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp lastFourDigitNumberExtraction = RegExp(
    r'(?:no\.|num|ending in|ending with|\*\*|رقم|حساب|بطاقة|بطاقتك|بـ|المنتهية بـ)\s*[*Xx]*(\d{4})',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp merchantExtraction = RegExp(
    r'(?:merchant|pos|at|with|عند|لدى|لدي|فى|في)\s+([^0-9\r\n]+)',
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

  static final amountWithCurrencyPattern = StringBuffer()
    ..write('(?:(')
    ..write(_currencyPattern)
    ..write(
      ')\\s*([0-9][0-9,\\.\\u066b\\u066c]*))|',
    ) // Group 1: Currency, Group 2: Amount
    ..write('(?:([0-9][0-9,\\.\\u066b\\u066c]*)\\s*(')
    ..write(_currencyPattern)
    ..write('))'); // Group 3: Amount, Group 4: Currency

  static final RegExp amountWithCurrencyRegex = RegExp(
    amountWithCurrencyPattern.toString(),
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp dateRegex = RegExp(
    r"\b(?:\d{1,2}[-/\.]\d{1,2}(?:[-/\.](?:\d{4}|\d{2}))?)\b",
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp timeRegex = RegExp(
    r'(\d{1,2}:\d{2})',
    caseSensitive: false,
    unicode: true,
  );

  //* Transaction Type Keywords
  static const List<String> expenseKeywords = [
    'purchase',
    'debited',
    'transfer from',
    'payment',
    'withdrawal',
    'spent',
    'تنفيذ',
    'خصم',
    'شراء',
    'تحويل من',
    'سحب',
    'تنفيذ تحويل',
    'مدفوعات',
    'مصروف',
  ];

  static const List<String> incomeKeywords = [
    'deposit',
    'credited',
    'transfer to',
    'refund',
    'received',
    'إضافة',
    'إضافة تحويل',
    'إيداع',
    'استرداد',
  ];
}
