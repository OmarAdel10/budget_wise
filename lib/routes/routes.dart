import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/screens/accounts_screen.dart';
import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/category/view/screens/add_category_screen.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/home/view/screens/home_screen.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/onboarding/view/screens/splash_screen.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view/screens/add_saving_goal_screen.dart';
import 'package:budget_wise/savings/view/screens/edit_saving_goal_screen.dart';
import 'package:budget_wise/savings/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/savings/view/screens/savings_screen.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/settings/view/screens/passcode_setup_screen.dart';
import 'package:budget_wise/settings/view/screens/settings_screen.dart';
import 'package:budget_wise/statistics/view/screens/statistics_screen.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_screen.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
import 'package:budget_wise/transaction/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/transaction/view/screens/transaction_type_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  static Route<dynamic>? Function(RouteSettings)? onGenerateRoutes(
    BuildContext context,
  ) => (settings) {
    //* Main Screens Routes
    return mainScreensRoutes(context, settings) ??
        //* Add Screens Routes
        addScreensRoutes(context, settings) ??
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
      case SplashScreen.routeName:
        return PageTransition(
          type: PageTransitionType.fade,
          reverseType: PageTransitionType.fade,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const SplashScreen(),
        );
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
      case AllTransactionsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AllTransactionsScreen(),
        );
      case PendingSmsTransactionsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: PendingSmsTransactionsScreen(),
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
      case SavingsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const SavingsScreen(),
        );
      case AccountsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AccountsScreen(),
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
      case StatisticsScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const StatisticsScreen(),
        );
      default:
        return null;
    }
  }

  static Route<dynamic>? addScreensRoutes(
    BuildContext context,
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AddCategoryScreen.routeName:
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          reverseType: PageTransitionType.topToBottom,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AddCategoryScreen(),
        );
      case AddTransactionScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          reverseType: PageTransitionType.topToBottom,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: AddTransactionScreen(
            initialAccountId: args?['initialAccountId'] as String?,
            initialAmount: args?['initialAmount'] as double?,
          ),
        );
      case AddSavingGoalScreen.routeName:
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          reverseType: PageTransitionType.topToBottom,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AddSavingGoalScreen(),
        );
      case AddAccountScreen.routeName:
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          reverseType: PageTransitionType.topToBottom,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AddAccountScreen(),
        );
      case AddSubscriptionScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        final subModel = args?['subModel'] as SubscriptionModel?;
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          reverseType: PageTransitionType.topToBottom,
          ctx: context,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: AddSubscriptionScreen(subscriptionToEdit: subModel),
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
      case CategoryDetailScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: CategoryDetailScreen(),
        );
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
      case TransactionTypeDetailScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: TransactionTypeDetailScreen(),
        );
      case TransactionDetailScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: TransactionDetailScreen(),
        );
      case AccountDetailScreen.routeName:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          reverseType: PageTransitionType.leftToRight,
          ctx: context,
          duration: Duration(milliseconds: 500),
          reverseDuration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          settings: settings,
          child: const AccountDetailScreen(),
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
        final goal = args?['savingGoal'] as SavingsModel;
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
