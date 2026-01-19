class AccountConstants {
  static const Map<String, String> supportedCurrencies = {
    'EGP': 'Egyptian Pound',
    'USD': 'United States Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound Sterling',
    'SAR': 'Saudi Riyal',
    'AED': 'United Arab Emirates Dirham',
    'KWD': 'Kuwaiti Dinar',
  };

  static const Set<String> egyptBankWhiteListNames = {
      // Public Banks & Variations
      "national bank of egypt", "national bank egypt", "nbe", "al ahli bank",
      "banque misr", "bank misr",
      "banque du caire", "bank du caire",

      // Private Banks & Variations
      "commercial international bank", "cib",
      "qatar national bank", "qnb", "qnb al ahli",
      "arab african international bank", "aaib",
      "alexbank", "alexandria bank", "bank of alexandria",
      "hsbc", "hsbc bank egypt", "hsbc bank egypt s.a.e",
      "faisal islamic bank", "faisal islamic bank of egypt",
      "abu dhabi islamic bank", "adib", "adib egypt",
      "abu dhabi commercial bank", "adcb", "adcb egypt",
      "bank nxt", "nxt bank",
      "credit agricole", "credit agricole egypt",
      "emirates nbd", "emirates nbd egypt",
      "fab misr", "first abu dhabi bank", "first abu dhabi bank misr",
      "eg bank", "egyptian gulf bank",
      "saib", "societe arabe internationale de banque",
      "bank abc", "bank abc egypt", "arab banking corporation",
      "attijariwafa", "attijariwafa bank egypt",
      "al ahli bank of kuwait", "abk", "abk egypt",
      "national bank of kuwait", "nbk", "nbk egypt",

      // Specialized Banks
      "housing and development bank", "hdb", "hd bank",
      "agricultural bank of egypt", "abe",
      "industrial development bank", "idb",
      "the united bank", "united bank",
      "suez canal bank",
      "arab investment bank", "ai bank",
      "central bank of egypt", "cbe",
    };
}