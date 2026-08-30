import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/view/screens/edit_saving_goal_screen.dart';
import 'package:budget_wise/buckets/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/buckets/view/screens/buckets_screen.dart';
import 'package:budget_wise/home/view/screens/home_screen.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/settings/view/screens/passcode_setup_screen.dart';
import 'package:budget_wise/settings/view/screens/settings_screen.dart';
import 'package:budget_wise/statistics/view/screens/statistics_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  static Route<dynamic>? Function(RouteSettings)? onGenerateRoutes(
    BuildContext context,
  ) => (settings) {
    //* Main Screens Routes
    return mainScreensRoutes(context, settings) ??
        //* Details Screens Routes
        detailsScreensRoutes(context, settings) ??
        //* Edit Screens Routes
        editScreensRoutes(context, settings);
  };
  static Route<dynamic>? mainScreensRoutes(
    BuildContext context,
    RouteSettings settings,
  ) {
    switch (settings.name) {
      //* Main Screens Routes
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
          type: PageTransitionType.fade,
          reverseType: PageTransitionType.leftToRightWithFade,
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
          reverseType: PageTransitionType.leftToRightWithFade,
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
          reverseType: PageTransitionType.leftToRightWithFade,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const ForgotPasswordScreen(),
        );
      case LocalAuthScreen.routeName:
        return PageTransition(
          type: PageTransitionType.fade,
          ctx: context,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const LocalAuthScreen(),
        );
      case PasscodeSetupScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const PasscodeSetupScreen(),
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
      case HomeScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const HomeScreen(),
        );
      case SubscriptionScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const SubscriptionScreen(),
        );
      case BucketsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const BucketsScreen(),
        );
      case SettingsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const SettingsScreen(),
        );
      case StatisticsScreenBody.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const StatisticsScreenBody(),
        );
      default:
        return null;
    }
  }

  static Route<dynamic>? detailsScreensRoutes(
    BuildContext context,
    RouteSettings settings,
  ) {
    switch (settings.name) {
      // case CategoryDetailScreen.routeName:
      //   return PageTransition(
      //     type: PageTransitionType.rightToLeft,
      //     reverseType: PageTransitionType.leftToRight,
      //     ctx: context,
      //     duration: Duration(milliseconds: 500),
      //     reverseDuration: Duration(milliseconds: 500),
      //     curve: Curves.easeIn,
      //     settings: settings,
      //     child: CategoryDetailScreen(),
      //   );
      case SavingGoalDetailScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: SavingGoalDetailScreen(
            savingGoalId: args['savingGoalId'] as String,
          ),
        );
      case SubscriptionDetailsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: SubscriptionDetailsScreen(),
        );
      default:
        return null;
    }
  }

  static Route<dynamic>? editScreensRoutes(
    BuildContext context,
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case EditSavingGoalScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        final goal = args?['savingGoal'] as SavingGoalModel;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: EditSavingGoalScreen(goal: goal),
        );
      case EditAccountScreen.routeName:
        final account = settings.arguments as AccountModel;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: EditAccountScreen(account: account),
        );
      case EditProfileScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: EditProfileScreen(
            authRepository: context.read<AuthRepository>(),
          ),
        );
      default:
        return null;
    }
  }
}
