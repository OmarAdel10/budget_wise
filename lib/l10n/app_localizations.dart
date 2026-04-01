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

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

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

  /// No description provided for @earningsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Earnings by Category'**
  String get earningsByCategory;

  /// No description provided for @savingsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Savings by Goal'**
  String get savingsByCategory;

  /// No description provided for @savingsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Savings Breakdown'**
  String get savingsBreakdown;

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

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Future.'**
  String get onboardingTitle3;

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

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Create an account to sync your savings across devices and never lose progress.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'If you proceed without an account, your data will be stored locally only. This means your information will be permanently lost if the app is deleted or your device is lost.'**
  String get onboardingDisclaimer;

  /// No description provided for @onboardingLoginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Login/SignUp'**
  String get onboardingLoginSignUp;

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get onboardingSkipForNow;

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

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

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

  /// No description provided for @addAccountCardHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Holder'**
  String get addAccountCardHolderLabel;

  /// No description provided for @addAccountCardHolderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Card Holder Name'**
  String get addAccountCardHolderPlaceholder;

  /// No description provided for @addAccountBankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get addAccountBankNameLabel;

  /// No description provided for @addAccountBankNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap To Select Bank'**
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

  /// No description provided for @cardHolderCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name Can\'t Left Empty'**
  String get cardHolderCantLeftEmpty;

  /// No description provided for @youShouldEnterAValidCardHolderName.
  ///
  /// In en, this message translates to:
  /// **'You Should Enter A Valid Card Holder Name'**
  String get youShouldEnterAValidCardHolderName;

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

  /// No description provided for @accountDetailUpdatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {time} ago'**
  String accountDetailUpdatedAgo(Object time);

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @alertOnLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Alert on low balance'**
  String get alertOnLowBalance;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This action cannot be undone and will remove all associated data.'**
  String get deleteAccountConfirmation;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No Account'**
  String get noAccount;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @cloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync securely to the cloud & backup your data'**
  String get cloudBackupDesc;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Local Only'**
  String get localOnly;

  /// No description provided for @localOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Work offline on this device only'**
  String get localOnlyDesc;

  /// No description provided for @authChoiceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings. Local data won\'t sync if you choose local-only now.'**
  String get authChoiceDisclaimer;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @enableCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Enable Cloud Sync'**
  String get enableCloudSync;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @lastSyncTime.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSyncTime(Object time);

  /// No description provided for @localOnlyStatus.
  ///
  /// In en, this message translates to:
  /// **'Local only (no cloud sync)'**
  String get localOnlyStatus;

  /// No description provided for @offlineWarning.
  ///
  /// In en, this message translates to:
  /// **'You are working offline. Changes will be synced once you login.'**
  String get offlineWarning;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing your data...'**
  String get syncInProgress;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Will retry later.'**
  String get syncFailed;

  /// No description provided for @ofWord.
  ///
  /// In en, this message translates to:
  /// **'Of'**
  String get ofWord;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'CARDHOLDER'**
  String get cardHolder;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access the app'**
  String get biometricReason;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available'**
  String get biometricNotAvailable;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get enterCategoryName;

  /// No description provided for @enterValidBudget.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid budget amount'**
  String get enterValidBudget;

  /// No description provided for @tapToChangeIcon.
  ///
  /// In en, this message translates to:
  /// **'Tap to change icon'**
  String get tapToChangeIcon;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @shoppingExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Shopping'**
  String get shoppingExample;

  /// No description provided for @setBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Set Budget Limit'**
  String get setBudgetLimit;

  /// No description provided for @trackBudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'Track spending against a monthly budget'**
  String get trackBudgetDesc;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategory;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get selectAccount;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @selectAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccountLabel;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncomeTitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseTitle;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get noCategory;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @continueOnboarding.
  ///
  /// In en, this message translates to:
  /// **'You can continue the onboarding process.'**
  String get continueOnboarding;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed or cancelled.'**
  String get loginFailed;

  /// No description provided for @tryAgainLocally.
  ///
  /// In en, this message translates to:
  /// **'Please try again or continue locally.'**
  String get tryAgainLocally;

  /// No description provided for @enterValidIncome.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid income amount.'**
  String get enterValidIncome;

  /// No description provided for @amountGreaterThan1.
  ///
  /// In en, this message translates to:
  /// **'Amount should be greater than 1.'**
  String get amountGreaterThan1;

  /// No description provided for @selectIncomeSource.
  ///
  /// In en, this message translates to:
  /// **'Please select an income source'**
  String get selectIncomeSource;

  /// No description provided for @disclaimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer:'**
  String get disclaimerLabel;

  /// No description provided for @newSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'New Saving Goal'**
  String get newSavingGoal;

  /// No description provided for @enterGoalName.
  ///
  /// In en, this message translates to:
  /// **'e.g., New Car'**
  String get enterGoalName;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @savingRegularlyInfo.
  ///
  /// In en, this message translates to:
  /// **'Saving regularly helps you reach your goals faster.'**
  String get savingRegularlyInfo;

  /// No description provided for @saveSmallAmountsInfo.
  ///
  /// In en, this message translates to:
  /// **'Save small amounts daily to reach your goal.'**
  String get saveSmallAmountsInfo;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get accountDeleted;

  /// No description provided for @pendingSmsTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending SMS Transactions'**
  String get pendingSmsTransactionsTitle;

  /// No description provided for @noPendingSmsTransactions.
  ///
  /// In en, this message translates to:
  /// **'No pending SMS transactions.'**
  String get noPendingSmsTransactions;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// No description provided for @cardLast4Digits.
  ///
  /// In en, this message translates to:
  /// **'Card Last 4 Digits'**
  String get cardLast4Digits;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @noAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No accounts available. Please add an account first.'**
  String get noAccountsAvailable;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @smsSetupAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Setup Assistant'**
  String get smsSetupAssistantTitle;

  /// No description provided for @smsSetupAssistantHeader.
  ///
  /// In en, this message translates to:
  /// **'Automate your tracking'**
  String get smsSetupAssistantHeader;

  /// No description provided for @smsSetupAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We can scan your inbox to find your previous transactions and automate the future ones.'**
  String get smsSetupAssistantSubtitle;

  /// No description provided for @smsSetupAssistantScanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Inbox'**
  String get smsSetupAssistantScanButton;

  /// No description provided for @smsSetupAssistantScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning your inbox...'**
  String get smsSetupAssistantScanning;

  /// No description provided for @smsSetupAssistantNoTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found in your inbox.'**
  String get smsSetupAssistantNoTransactionsFound;

  /// No description provided for @smsSetupAssistantSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scan complete! {count} transactions found.'**
  String smsSetupAssistantSuccess(Object count);

  /// No description provided for @smsSetupAssistantError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while scanning.'**
  String get smsSetupAssistantError;

  /// No description provided for @smsSetupAssistantPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Guided setup for your card accounts.'**
  String get smsSetupAssistantPlaceholder;

  /// No description provided for @selectBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Bank'**
  String get selectBankTitle;

  /// No description provided for @searchBankPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for your bank'**
  String get searchBankPlaceholder;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit Draft'**
  String get editDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft Saved'**
  String get draftSaved;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft Deleted'**
  String get draftDeleted;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @totalSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Total Subscriptions'**
  String get totalSubscriptions;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get noSubscriptions;

  /// No description provided for @thisSubscriptionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This subscription is not available'**
  String get thisSubscriptionNotAvailable;

  /// No description provided for @totalMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Spend'**
  String get totalMonthlySpend;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'{count} Active Subscriptions'**
  String activeSubscriptions(Object count);

  /// No description provided for @inActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'{count} InActive Subscriptions'**
  String inActiveSubscriptions(Object count);

  /// No description provided for @overdueSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue Subscriptions'**
  String overdueSubscriptions(Object count);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @nextBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextBillingDate(Object date);

  /// No description provided for @dueToBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Due To: {date}'**
  String dueToBillingDate(Object date);

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscription'**
  String get editSubscription;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// No description provided for @payToRenew.
  ///
  /// In en, this message translates to:
  /// **'Pay to Renew'**
  String get payToRenew;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get billingCycle;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} days before'**
  String daysBefore(Object count);

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @halfYearly.
  ///
  /// In en, this message translates to:
  /// **'Half-Yearly'**
  String get halfYearly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @deleteSubscription.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription'**
  String get deleteSubscription;

  /// No description provided for @subscriptionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Subscription Deleted'**
  String get subscriptionDeleted;

  /// No description provided for @subscriptionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Subscription Name (e.g. Netflix)'**
  String get subscriptionNameHint;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egp;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @nextRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Next Renewal Date'**
  String get nextRenewalDate;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @noRecentTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Recent Transactions Found.'**
  String get noRecentTransactionsFound;

  /// No description provided for @noAccountsAvailableForSelectedCurrency.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Available For The Selected Currency.'**
  String get noAccountsAvailableForSelectedCurrency;

  /// No description provided for @lowBalanceAlertAmount.
  ///
  /// In en, this message translates to:
  /// **'Low Balance Alert Amount'**
  String get lowBalanceAlertAmount;

  /// No description provided for @yourAccountBalanceIsBelowTheSpecifiedLowBalanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Your account balance is below the specified low balance amount.'**
  String get yourAccountBalanceIsBelowTheSpecifiedLowBalanceAmount;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// No description provided for @lastUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last Updated At:'**
  String get lastUpdatedAt;

  /// No description provided for @lowBalanceWarning.
  ///
  /// In en, this message translates to:
  /// **'Low Balance Warning'**
  String get lowBalanceWarning;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @setPasscode.
  ///
  /// In en, this message translates to:
  /// **'Set Passcode'**
  String get setPasscode;

  /// No description provided for @changePasscode.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get changePasscode;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get useBiometrics;

  /// No description provided for @enterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter Passcode'**
  String get enterPasscode;

  /// No description provided for @confirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passcode'**
  String get confirmPasscode;

  /// No description provided for @passcodeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passcodes do not match'**
  String get passcodeMismatch;

  /// No description provided for @passcodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Passcode'**
  String get passcodeIncorrect;

  /// No description provided for @passcodeSet.
  ///
  /// In en, this message translates to:
  /// **'Passcode Set Successfully'**
  String get passcodeSet;

  /// No description provided for @noSavingsGoalsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'There is no Savings Goals this month'**
  String get noSavingsGoalsThisMonth;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @savingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Savings Deleted'**
  String get savingDeleted;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @todoSavings.
  ///
  /// In en, this message translates to:
  /// **'Todo Savings'**
  String get todoSavings;

  /// No description provided for @completedDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed days'**
  String get completedDaysLabel;

  /// No description provided for @savingsGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{percentage}%'**
  String savingsGoalProgress(int percentage);

  /// No description provided for @savingsGoalAmountProgress.
  ///
  /// In en, this message translates to:
  /// **'{currency}{current} / {currency}{target}'**
  String savingsGoalAmountProgress(String currency, num current, num target);

  /// No description provided for @setByAmount.
  ///
  /// In en, this message translates to:
  /// **'Set by Amount'**
  String get setByAmount;

  /// No description provided for @setByDays.
  ///
  /// In en, this message translates to:
  /// **'Set by Days'**
  String get setByDays;

  /// No description provided for @numberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Number of Days'**
  String get numberOfDays;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @dailySavingAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily Saving Amount'**
  String get dailySavingAmount;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @methodDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get methodDefault;

  /// No description provided for @methodConstant.
  ///
  /// In en, this message translates to:
  /// **'Constant'**
  String get methodConstant;

  /// No description provided for @methodDouble.
  ///
  /// In en, this message translates to:
  /// **'2x Default'**
  String get methodDouble;

  /// No description provided for @methodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get methodCustom;

  /// No description provided for @methodDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Method'**
  String get methodDefaultTitle;

  /// No description provided for @methodDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Save an increasing amount every day: Day 1 = \$1, Day 2 = \$2, etc.'**
  String get methodDefaultDesc;

  /// No description provided for @methodConstantTitle.
  ///
  /// In en, this message translates to:
  /// **'Constant Method'**
  String get methodConstantTitle;

  /// No description provided for @methodConstantDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a fixed amount every single day (e.g., \$10 every day).'**
  String get methodConstantDesc;

  /// No description provided for @methodDoubleTitle.
  ///
  /// In en, this message translates to:
  /// **'2x Default Method'**
  String get methodDoubleTitle;

  /// No description provided for @methodDoubleDesc.
  ///
  /// In en, this message translates to:
  /// **'Double the default pattern: Day 1 = \$2, Day 2 = \$4, etc.'**
  String get methodDoubleDesc;

  /// No description provided for @methodCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Method'**
  String get methodCustomTitle;

  /// No description provided for @methodCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'Add manual entries whenever you want. Complete flexibility!'**
  String get methodCustomDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @enterDays.
  ///
  /// In en, this message translates to:
  /// **'Enter Days'**
  String get enterDays;

  /// No description provided for @infoEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a Target Amount. We\'ll automatically calculate the required Number of Days and Target Date based on your method.'**
  String get infoEnterAmount;

  /// No description provided for @infoEnterDays.
  ///
  /// In en, this message translates to:
  /// **'Enter the Number of Days. We\'ll automatically calculate the Target Amount and Target Date based on your method.'**
  String get infoEnterDays;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @inActive.
  ///
  /// In en, this message translates to:
  /// **'inActive'**
  String get inActive;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @noPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'No payment history found.'**
  String get noPaymentHistory;

  /// No description provided for @markedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid!'**
  String get markedAsPaid;

  /// No description provided for @deleteSubscriptionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this subscription?'**
  String get deleteSubscriptionConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reminderInfo.
  ///
  /// In en, this message translates to:
  /// **'Get notified before your subscription renews.'**
  String get reminderInfo;

  /// No description provided for @reminderBeforeDays.
  ///
  /// In en, this message translates to:
  /// **'Reminder Before Days'**
  String get reminderBeforeDays;

  /// No description provided for @subNameCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Subscription Name Can\'t Left Empty'**
  String get subNameCantLeftEmpty;

  /// No description provided for @amountCantLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Amount Can\'t Left Empty'**
  String get amountCantLeftEmpty;

  /// No description provided for @inActiveAndOverdue.
  ///
  /// In en, this message translates to:
  /// **'inActive & Overdue'**
  String get inActiveAndOverdue;

  /// No description provided for @subPaying.
  ///
  /// In en, this message translates to:
  /// **'{name} Payment'**
  String subPaying(String name);

  /// No description provided for @subNote.
  ///
  /// In en, this message translates to:
  /// **'{name} subscription, renewing on {date}'**
  String subNote(String name, String date);

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get activeStatus;

  /// No description provided for @trackingStatus.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingStatus;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @bankMargin.
  ///
  /// In en, this message translates to:
  /// **'Bank Margin (%)'**
  String get bankMargin;

  /// No description provided for @bankMarginInfo.
  ///
  /// In en, this message translates to:
  /// **'Added to conversion rates'**
  String get bankMarginInfo;

  /// No description provided for @subscriptionCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subscription created successfully!'**
  String get subscriptionCreatedSuccessfully;

  /// No description provided for @subscriptionUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated successfully!'**
  String get subscriptionUpdatedSuccessfully;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @conversionError.
  ///
  /// In en, this message translates to:
  /// **'Could not load exchange rates'**
  String get conversionError;

  /// No description provided for @manualOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual Override'**
  String get manualOverride;

  /// No description provided for @conversionEstimate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Estimate'**
  String get conversionEstimate;

  /// No description provided for @manualConversion.
  ///
  /// In en, this message translates to:
  /// **'Manual Conversion'**
  String get manualConversion;

  /// No description provided for @estimatedConversion.
  ///
  /// In en, this message translates to:
  /// **'Estimated Conversion'**
  String get estimatedConversion;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// No description provided for @budgetExceededDescription.
  ///
  /// In en, this message translates to:
  /// **'Your spending in {category} has exceeded your monthly budget limit. Click save again if you want to register it anyway.'**
  String budgetExceededDescription(String category);

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get saveAnyway;

  /// No description provided for @confirmAnyway.
  ///
  /// In en, this message translates to:
  /// **'Confirm Anyway'**
  String get confirmAnyway;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @conversionError.
  ///
  /// In en, this message translates to:
  /// **'Could not load exchange rates'**
  String get conversionError;

  /// No description provided for @manualOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual Override'**
  String get manualOverride;

  /// No description provided for @conversionEstimate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Estimate'**
  String get conversionEstimate;

  /// No description provided for @manualConversion.
  ///
  /// In en, this message translates to:
  /// **'Manual Conversion'**
  String get manualConversion;

  /// No description provided for @estimatedConversion.
  ///
  /// In en, this message translates to:
  /// **'Estimated Conversion'**
  String get estimatedConversion;
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
