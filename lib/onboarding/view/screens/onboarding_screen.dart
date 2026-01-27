import 'dart:developer';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/models/user_model.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
  String? _incomeCategoryId;
  List<CategoryModel> _selectedCategories = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onLoginSignUpPressed() {
    Navigator.of(context)
        .pushNamed(
          LoginScreen.routeName,
          arguments: {'loginRouting': LoginRouting.fromOnboarding},
        )
        .then((result) {
          if (!mounted) return;
          if (result == true) {
            log("Returned from Login Screen after successful login.");
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Login successful! You can continue the onboarding process.',
                ),
              ),
            );
          } else {
            log("Returned from Login Screen without successful login.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Login failed or cancelled. Please try again or continue locally.',
                ),
              ),
            );
          }
        });
  }

  void _onSkipForNowPressed() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 4) {
      // Validation check before moving from Income Page (Page 3)
      if (_currentPage == 3) {
        if (_incomeAmount < 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter a valid income amount.\nAmount should be greater than 100.',
              ),
            ),
          );
          return;
        }
        if (_incomeCategoryId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an income source')),
          );
          return;
        }
        final DateFormat date = DateFormat('dd/MM/yyyy');
        final transaction = TransactionModel(
          type: TransactionType.income,
          transactionAmount: _incomeAmount,
          transactionTitle: 'Income${date.format(DateTime.now())}',
          transactionDate: DateTime.now(),
          categoryId: _incomeCategoryId!,
          accountId: context.read<AccountBloc>().state.accountsList.first.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        context.read<TransactionBloc>().add(
          TransactionEventCreateTransaction(transaction),
        );
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Validation (Category Selection - Page 4)
      if (_selectedCategories.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSelectCategories),
          ),
        );
        return;
      } else {
        for (final category in _selectedCategories) {
          context.read<CategoryBloc>().add(
            CategoryEventCreateCategory(category),
          );
        }
      }

      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    log("Onboarding Completed!");
    log("Income: $_incomeAmount, CategoryId: $_incomeCategoryId");
    log(
      "Categories: ${_selectedCategories.map((e) => e.categoryTitle).toList()}",
    );
    context.read<SettingsBloc>().add(SettingsEventOnBoardingChange());
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
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
                    onDataChanged: (amount, categoryId) {
                      setState(() {
                        _incomeAmount = amount;
                        _incomeCategoryId = categoryId;
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
                        'Disclaimer:',
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
