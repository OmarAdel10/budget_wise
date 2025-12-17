import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:budget_wise/shared/app_theme.dart';

import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:page_transition/page_transition.dart'; // Import OnboardingScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case OnboardingScreen.routeName:
            return PageTransition(
              type: PageTransitionType.fade,
              reverseType: PageTransitionType.fade,
              ctx: context,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              settings: settings,
              child: const OnboardingScreen(),
            );
          case LoginScreen.routeName:
            return PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              reverseType: PageTransitionType.fade,
              ctx: context,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              settings: settings,
              child: const LoginScreen(),
            );
          case SignUpScreen.routeName:
            return PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              reverseType: PageTransitionType.fade,
              ctx: context,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              settings: settings,
              child: const SignUpScreen(),
            );
          case ForgotPasswordScreen.routeName:
            return PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              reverseType: PageTransitionType.fade,
              ctx: context,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              settings: settings,
              child: const ForgotPasswordScreen(),
            );
          case MainScreen.routeName:
            return PageTransition(
              type: PageTransitionType.fade,
              ctx: context,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              settings: settings,
              child: const MainScreen(),
            );
          default:
            return null;
        }
      },
      home: const OnboardingScreen(),
    );
  }
}
