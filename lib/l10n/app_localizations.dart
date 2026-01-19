import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'BudgetWise'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get navSavings;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @allSavingGoals.
  ///
  /// In en, this message translates to:
  /// **'All Saving Goals'**
  String get allSavingGoals;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @financialStatistics.
  ///
  /// In en, this message translates to:
  /// **'Financial Statistics'**
  String get financialStatistics;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @currentSavings.
  ///
  /// In en, this message translates to:
  /// **'Current Savings'**
  String get currentSavings;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @secureApp.
  ///
  /// In en, this message translates to:
  /// **'Secure The App Using BioMetrics'**
  String get secureApp;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @dailySavings.
  ///
  /// In en, this message translates to:
  /// **'Daily Savings'**
  String get dailySavings;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @notesOP.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOP;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BudgetWise'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Income & Budget'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances with BudgetWise. Track your income, expenses, and savings effortlessly.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Add your monthly income and define custom categories to split your budget.'**
  String get onboardingDesc2;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @incomeSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Profile'**
  String get incomeSetupTitle;

  /// No description provided for @incomeSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your income profile.'**
  String get incomeSetupDesc;

  /// No description provided for @incomeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get incomeAmountLabel;

  /// No description provided for @incomeSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Income Source'**
  String get incomeSourceLabel;

  /// No description provided for @sourceWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sourceWork;

  /// No description provided for @sourcePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get sourcePersonal;

  /// No description provided for @sourceFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get sourceFreelance;

  /// No description provided for @sourceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sourceOther;

  /// No description provided for @categorySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Expenses Categories'**
  String get categorySelectionTitle;

  /// No description provided for @categorySelectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose at least 3 categories to track.'**
  String get categorySelectionDesc;

  /// No description provided for @errorSelectCategories.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 3 categories.'**
  String get errorSelectCategories;

  /// No description provided for @catSmoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get catSmoking;

  /// No description provided for @catEating.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get catEating;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transporting'**
  String get catTransport;

  /// No description provided for @catUtils.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtils;

  /// No description provided for @catDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get catDebts;

  /// No description provided for @catInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get catInvestments;

  /// No description provided for @catMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Recharge'**
  String get catMobile;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get catHealth;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @bioMetrics.
  ///
  /// In en, this message translates to:
  /// **'BioMetrics'**
  String get bioMetrics;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @redBorderMeansThatYouCantChange.
  ///
  /// In en, this message translates to:
  /// **'Red Border Means That You Can\'t Change'**
  String get redBorderMeansThatYouCantChange;

  /// No description provided for @thisFielditsOnlyForDisplay.
  ///
  /// In en, this message translates to:
  /// **'This Field, it\'s Only For Display.'**
  String get thisFielditsOnlyForDisplay;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @syncToCloud.
  ///
  /// In en, this message translates to:
  /// **'Sync To Cloud'**
  String get syncToCloud;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetails;

  /// No description provided for @incomeDetails.
  ///
  /// In en, this message translates to:
  /// **'Income Details'**
  String get incomeDetails;

  /// No description provided for @amountSpent.
  ///
  /// In en, this message translates to:
  /// **'Amount Spent'**
  String get amountSpent;

  /// No description provided for @amountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount Received'**
  String get amountReceived;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @hasNoBudget.
  ///
  /// In en, this message translates to:
  /// **'Has No Budget'**
  String get hasNoBudget;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction Deleted'**
  String get transactionDeleted;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category Deleted'**
  String get categoryDeleted;

  /// No description provided for @yourExpensesExceedYourIncome.
  ///
  /// In en, this message translates to:
  /// **'Your expenses exceed your income'**
  String get yourExpensesExceedYourIncome;

  /// No description provided for @earningsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Earnings by Category'**
  String get earningsByCategory;

  /// No description provided for @noEarningsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No earnings for this month'**
  String get noEarningsThisMonth;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this month'**
  String get noExpensesThisMonth;

  /// No description provided for @dailyTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Trend'**
  String get dailyTrend;

  /// No description provided for @categoryChart.
  ///
  /// In en, this message translates to:
  /// **'Category Chart'**
  String get categoryChart;

  /// No description provided for @sortHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get sortHighest;

  /// No description provided for @sortLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get sortLowest;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAZ;

  /// No description provided for @noDataThisMonth.
  ///
  /// In en, this message translates to:
  /// **'There is no data this month'**
  String get noDataThisMonth;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addAccountTitle;

  /// No description provided for @addAccountIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Account Identity'**
  String get addAccountIdentityHeader;

  /// No description provided for @addAccountSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup your source'**
  String get addAccountSetupTitle;

  /// No description provided for @addAccountSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your account details to start tracking your daily incremental savings.'**
  String get addAccountSetupSubtitle;

  /// No description provided for @addAccountAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get addAccountAccountNameLabel;

  /// No description provided for @addAccountAccountNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Checking'**
  String get addAccountAccountNamePlaceholder;

  /// No description provided for @addAccountTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get addAccountTypeHeader;

  /// No description provided for @addAccountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get addAccountTypeCash;

  /// No description provided for @addAccountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get addAccountTypeCard;

  /// No description provided for @addAccountInitialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get addAccountInitialBalanceLabel;

  /// No description provided for @addAccountInitialBalancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get addAccountInitialBalancePlaceholder;

  /// No description provided for @addAccountButtonAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccountButtonAddAccount;

  /// No description provided for @addAccountCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Card Details'**
  String get addAccountCardTitle;

  /// No description provided for @addAccountCardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get addAccountCardNumberLabel;

  /// No description provided for @addAccountBankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get addAccountBankNameLabel;

  /// No description provided for @addAccountBankNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bank Misr'**
  String get addAccountBankNamePlaceholder;

  /// No description provided for @addAccountCardExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get addAccountCardExpiryLabel;

  /// No description provided for @addAccountCardExpiryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get addAccountCardExpiryPlaceholder;

  /// No description provided for @addAccountCardCvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get addAccountCardCvvLabel;

  /// No description provided for @addAccountButtonSaveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get addAccountButtonSaveCard;

  /// No description provided for @addAccountCardSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Your card information is encrypted and secure'**
  String get addAccountCardSecureNote;

  /// No description provided for @addAccountAccountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get addAccountAccountNameRequired;

  /// No description provided for @addAccountAccountAdded.
  ///
  /// In en, this message translates to:
  /// **'Account added'**
  String get addAccountAccountAdded;

  /// No description provided for @addAccountCardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get addAccountCardSaved;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @yourAssets.
  ///
  /// In en, this message translates to:
  /// **'Your Assets'**
  String get yourAssets;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @linkMoreAccounts.
  ///
  /// In en, this message translates to:
  /// **'Link More Accounts'**
  String get linkMoreAccounts;

  /// No description provided for @continueWord.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWord;

  /// No description provided for @accountNameCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Account Name Can\'t Left Empty'**
  String get accountNameCantLeftEmpty;

  /// No description provided for @youShouldEnterMoreThan3Characters.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter More Than 3 Characters'**
  String get youShouldEnterMoreThan3Characters;

  /// No description provided for @initialBalanceCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance Can\'t Left Empty'**
  String get initialBalanceCantLeftEmpty;

  /// No description provided for @youShouldEnterAValidBalance.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter A Valid Balance'**
  String get youShouldEnterAValidBalance;

  /// No description provided for @bankNameCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Bank Name Can\'t Left Empty'**
  String get bankNameCantLeftEmpty;

  /// No description provided for @youShouldEnterAValidBankName.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter A Valid Bank Name'**
  String get youShouldEnterAValidBankName;

  /// No description provided for @didYouMean.
  ///
  /// In en, this message translates to:
  /// **'Did you mean:'**
  String get didYouMean;

  /// No description provided for @questionMark.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get questionMark;

  /// No description provided for @cardNumberCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Card Number Can\'t Left Empty'**
  String get cardNumberCantLeftEmpty;

  /// No description provided for @youShouldEnterAValidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter A Valid Card Number'**
  String get youShouldEnterAValidCardNumber;

  /// No description provided for @expiryDateCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date Can\'t Left Empty'**
  String get expiryDateCantLeftEmpty;

  /// No description provided for @youShouldEnterAValidExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter A Valid Expiry Date'**
  String get youShouldEnterAValidExpiryDate;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: This card can not be used with any means cause the cvv is not provided so your card info is fully safe!'**
  String get disclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
