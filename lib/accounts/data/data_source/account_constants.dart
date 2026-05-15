class AccountConstants {
  static const Map<String, Map<String, String>> supportedCurrencies = {
    '🇪🇬': {'EGP': 'Egyptian Pound'},
    '🇺🇲': {'USD': 'United States Dollar'},
    '🇪🇺': {'EUR': 'Euro'},
    '🇬🇧': {'GBP': 'British Pound Sterling'},
    '🇸🇦': {'SAR': 'Saudi Riyal'},
    '🇦🇪': {'AED': 'United Arab Emirates Dirham'},
    '🇰🇼': {'KWD': 'Kuwaiti Dinar'},
  };

  static const Map<String, List<String>> egyptBanks = {
    "National Bank of Egypt": ["NBE", "NBE-SMS"],
    "Banque Misr": ["BM", "Banque Misr"],
    "Banque du Caire": ["BDC", "Banque du Caire"],
    "Commercial International Bank": ["CIB", "CIB-SMS"],
    "QNB Al Ahli": ["QNB", "QNB-SMS"],
    "Arab African International Bank": ["AAIB", "AAIB-SMS"],
    "Alex Bank": ["ALEXBANK", "AlexBank"],
    "HSBC Egypt": ["HSBC", "HSBC-EG"],
    "Faisal Islamic Bank": ["FAISAL", "FIBank"],
    "Credit Agricole Egypt": ["CAE", "CrAgEgy"],
    "Emirates NBD Egypt": ["ENBD", "EmNBD-EG"],
    "First Abu Dhabi Bank Misr": ["FABMISR", "FAB-EG"],
    "Housing and Development Bank": ["HDB", "HDBank"],
    "Suez Canal Bank": ["SCB", "SCBank"],
    "Al Ahli Bank of Kuwait": ["ABK", "ABK-KW"],
  };

  static const Map<String, String> walletProviders = {
    "Vodafone Cash": "vodafone",
    "WE Pay": "we",
    "Orange Cash": "orange",
    "Etisalat Cash": "etisalat",
  };
}
