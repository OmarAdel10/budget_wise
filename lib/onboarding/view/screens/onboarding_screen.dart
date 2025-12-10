
import 'dart:developer';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
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
  String? _incomeSource;
  List<String> _selectedCategories = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // Validation check before moving from Income Page (Page 2)
      if (_currentPage == 2) {
        if (_incomeAmount <= 0 && _incomeAmount < 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter a valid income amount.\nAmount should be greater than 100.',
              ),
            ),
          );
          return;
        }
        if (_incomeSource == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an income source')),
          );
          return;
        }
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Validation (Category Selection - Page 3)
      if (_selectedCategories.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSelectCategories),
          ),
        );
        return;
      }
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // TODO: Save state (_incomeAmount, _incomeSource, _selectedCategories)
    log("Onboarding Completed!");
    log("Income: $_incomeAmount, Source: $_incomeSource");
    log("Categories: $_selectedCategories");

    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
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
                      PhosphorIconsStyle.duotone,
                    ),
                  ),
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle2,
                    description: l10n.onboardingDesc2,
                    placeholderIcon: PhosphorIcons.piggyBank(
                      PhosphorIconsStyle.duotone,
                    ),
                  ),
                  IncomeSetupPage(
                    onDataChanged: (amount, source) {
                      setState(() {
                        _incomeAmount = amount;
                        _incomeSource = source;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  PageIndicatorWidget(count: 4, currentPage: _currentPage),
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
                            text: _currentPage == 3
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
        ),
      ),
    );
  }
}
