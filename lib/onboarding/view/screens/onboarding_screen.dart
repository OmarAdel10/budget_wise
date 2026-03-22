import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/utils/auth_constants.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/page_indicator_widget.dart';
import '../widgets/income_setup_page.dart';
import '../widgets/category_selection_page.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State for new pages
  double _incomeAmount = 0.0;
  String? _incomeCategoryTitle;
  String? _selectedIncomeCurrency;
  List<CategoryModel> _selectedCategories = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openAuthFlow({bool startWithLogin = true}) {
    final l10n = AppLocalizations.of(context)!;
    Future<dynamic> navFuture;
    if (startWithLogin) {
      navFuture = Navigator.of(context).pushNamed(
        LoginScreen.routeName,
        arguments: {'loginRouting': LoginRouting.fromOnboarding},
      );
    } else {
      navFuture = Navigator.of(
        context,
      ).pushNamed(SignUpScreen.routeName, arguments: true);
    }

    navFuture.then((result) {
      if (!mounted) return;

      if (result == 'switch_to_signup') {
        _openAuthFlow(startWithLogin: false);
      } else if (result == 'switch_to_login') {
        _openAuthFlow(startWithLogin: true);
      } else if (result == true) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        AppToast.show(
          context,
          type: AppToastType.success,
          title: l10n.loginSuccessful,
          description: l10n.continueOnboarding,
        );
      } else {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: l10n.loginFailed,
          description: l10n.tryAgainLocally,
        );
      }
    });
  }

  void _onLoginSignUpPressed() {
    _openAuthFlow(startWithLogin: true);
  }

  void _onSkipForNowPressed() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentPage < 4) {
      // Validation check before moving from Income Page (Page 3)
      if (_currentPage == 3) {
        if (_incomeAmount < 1) {
          AppToast.show(
            context,
            type: AppToastType.error,
            title: l10n.enterValidIncome,
            description: l10n.amountGreaterThan1,
          );
          return;
        }
        if (_incomeCategoryTitle == null) {
          AppToast.show(
            context,
            type: AppToastType.error,
            title: l10n.selectIncomeSource,
          );
          return;
        }
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Validation (Category Selection - Page 4)
      if (_selectedCategories.length < 3) {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: l10n.errorSelectCategories,
        );
        return;
      }

      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final l10n = AppLocalizations.of(context)!;

    // Generate IDs
    final accountId = const Uuid().v4();

    // 1. Create Main Account
    final accountModel = AccountModel(
      id: accountId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      accountType: AccountType.cash,
      title: 'Main Account',
      accountIcon: PhosphorIcons.currencyCircleDollar(
        PhosphorIconsStyle.regular,
      ),
      initialBalance: 0.0,
      balance: 0.0,
      currency: _selectedIncomeCurrency ?? 'EGP',
    );
    context.read<AccountBloc>().add(
      AccountEventCreateAccount(model: accountModel),
    );

    // 2. Create Default Income Categories
    final incomeCategoryNames = ['Work', 'Personal', 'Freelance', 'Other'];
    final incomeCategoryIcons = [
      PhosphorIconsRegular.briefcase,
      PhosphorIconsRegular.user,
      PhosphorIconsRegular.laptop,
      PhosphorIconsRegular.dotsThree,
    ];

    String? incomeCategoryId;

    for (int i = 0; i < incomeCategoryNames.length; i++) {
      final catId = const Uuid().v4();
      if (incomeCategoryNames[i].toLowerCase() ==
          _incomeCategoryTitle?.toLowerCase()) {
        incomeCategoryId = catId;
      }

      context.read<CategoryBloc>().add(
        CategoryEventCreateCategory(
          CategoryModel(
            id: catId,
            categoryTitle: incomeCategoryNames[i],
            categoryIcon: incomeCategoryIcons[i],
            budgetAmount: 0.0,
            type: TransactionType.income,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }

    // 3. Create User Selected Expense Categories
    for (final category in _selectedCategories) {
      context.read<CategoryBloc>().add(CategoryEventCreateCategory(category));
    }

    // 4. Create Initial Income Transaction
    if (incomeCategoryId != null) {
      final DateFormat date = DateFormat('dd/MM/yyyy');
      final transaction = TransactionModel(
        type: TransactionType.income,
        transactionAmount: _incomeAmount,
        transactionCurrency: _selectedIncomeCurrency ?? 'EGP',
        transactionTitle: '${l10n.income} ${date.format(DateTime.now())}',
        transactionDate: DateTime.now(),
        categoryId: incomeCategoryId,
        accountId: accountId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<TransactionBloc>().add(
        TransactionEventCreateTransaction(transaction),
      );

      context.read<SettingsBloc>().add(
        SettingsEventUpdateDefaultCurrency(
          newDefaultCurrency: _selectedIncomeCurrency ?? 'EGP',
        ),
      );
    }

    context.read<SettingsBloc>().add(SettingsEventOnBoardingFinished());
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(MainScreen.routeName, (route) => false);
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              // Top Bar / Logo Area
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to enforce next button validation
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle1,
                    description: l10n.onboardingDesc1,
                    placeholderIcon: PhosphorIcons.chartBar(
                      PhosphorIconsStyle.fill,
                    ),
                  ),
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle2,
                    description: l10n.onboardingDesc2,
                    placeholderIcon: PhosphorIcons.piggyBank(
                      PhosphorIconsStyle.fill,
                    ),
                  ),
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle3,
                    description: l10n.onboardingDesc3,
                    placeholderIcon: PhosphorIcons.cloudArrowUp(
                      PhosphorIconsStyle.fill,
                    ),
                  ),
                  IncomeSetupPage(
                    onDataChanged: (amount, categoryTitle, selectedCurrency) {
                      setState(() {
                        _incomeAmount = amount;
                        _incomeCategoryTitle = categoryTitle;
                        _selectedIncomeCurrency = selectedCurrency;
                      });
                    },
                  ),
                  CategorySelectionPage(
                    onSelectionChanged: (categories) {
                      setState(() {
                        _selectedCategories = categories;
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_currentPage == 2) ...[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.disclaimerLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        l10n.onboardingDisclaimer,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: .7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    PageIndicatorWidget(count: 5, currentPage: _currentPage),
                    const SizedBox(height: AppSpacing.xl),
                    // Button Logic
                    if (_currentPage == 0)
                      CustomButton(text: l10n.next, onPressed: _nextPage)
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: l10n.back,
                                  type: CustomButtonType.secondary,
                                  onPressed: _previousPage,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: CustomButton(
                                  text: l10n.onboardingSkipForNow,
                                  onPressed: _onSkipForNowPressed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomButton(
                            text: l10n.onboardingLoginSignUp,
                            onPressed: _onLoginSignUpPressed,
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    PageIndicatorWidget(count: 5, currentPage: _currentPage),
                    const SizedBox(height: AppSpacing.xl),
                    // Button Logic
                    if (_currentPage == 0)
                      CustomButton(text: l10n.next, onPressed: _nextPage)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: l10n.back,
                              type: CustomButtonType.secondary,
                              onPressed: _previousPage,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: CustomButton(
                              text: _currentPage == 4
                                  ? l10n.getStarted
                                  : l10n.next,
                              onPressed: _nextPage,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
