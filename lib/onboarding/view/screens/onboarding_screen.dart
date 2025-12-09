import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/page_indicator_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Auth or Main Screen
      // Navigator.pushReplacementNamed(context, '/login'); 
      // For now, since we don't have routes set up, we'll just log it.
      debugPrint("Navigate to Login");
    }
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
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle1,
                    description: l10n.onboardingDesc1,
                    placeholderIcon: PhosphorIcons.chartBar(PhosphorIconsStyle.duotone),
                  ),
                  OnboardingPageWidget(
                    title: l10n.onboardingTitle1, // Reusing title? Or should we have a second one? 
                    // Plan didn't specify second title details, using generic for now or same.
                    // Design analysis says "Welcome to BudgetWise" for screen 1.
                    // Screen 2 usually has different text. Let's use existing strings.
                    // Changed in ARB to have title 1. Detailed analysis of screen 2 png is needed.
                    // Screen 2 png view analysis: "Welcome to BudgetWise" also? 
                    // Let's assume dynamic for now. The ARB has onboardingDesc2.
                    // I will use Title 1 for both if no Title 2 is provided, or add a generic Title 2.
                    description: l10n.onboardingDesc2,
                    placeholderIcon: PhosphorIcons.piggyBank(PhosphorIconsStyle.duotone),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  PageIndicatorWidget(
                    count: 2,
                    currentPage: _currentPage,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_currentPage == 0)
                    CustomButton(
                      text: l10n.getStarted,
                      onPressed: _nextPage,
                    )
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
                            text: l10n.next,
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
