import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:budget_wise/shared/app_theme.dart';

import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/home/view/screens/add_category_screen.dart';
import 'package:budget_wise/home/view/screens/category_detail_screen.dart';
import 'package:budget_wise/home/view/screens/add_expense_screen.dart';
import 'package:budget_wise/savings/view/screens/add_saving_goal_screen.dart';
import 'package:budget_wise/savings/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/home/view/screens/income_detail_screen.dart';
import 'package:budget_wise/home/view/screens/outcome_detail_screen.dart';
import 'package:budget_wise/home/view/screens/expense_detail_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
  );
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(create: (context) => TransactionBloc()),
        BlocProvider(create: (context) => CategoryBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepo = AuthRepository();
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
          locale: Locale(state.model.language),
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
              case AddCategoryScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.bottomToTop,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddCategoryScreen(),
                );
              case CategoryDetailScreen.routeName:
                final args = settings.arguments as Map<String, dynamic>;
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: CategoryDetailScreen(category: args),
                );
              case AddExpenseScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.bottomToTop,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddExpenseScreen(),
                );
              case AddSavingGoalScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.bottomToTop,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddSavingGoalScreen(),
                );
              case SavingGoalDetailScreen.routeName:
                final args = settings.arguments as Map<String, dynamic>;
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: SavingGoalDetailScreen(goal: args),
                );
              case IncomeDetailScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const IncomeDetailScreen(),
                );
              case OutcomeDetailScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const OutcomeDetailScreen(),
                );
              case ExpenseDetailScreen.routeName:
                final args = settings.arguments as Map<String, dynamic>;
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: ExpenseDetailScreen(expense: args),
                );
              case LocalAuthScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  reverseType: PageTransitionType.fade,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const LocalAuthScreen(),
                );
              case EditProfileScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  reverseType: PageTransitionType.fade,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const EditProfileScreen(),
                );
              default:
                return null;
            }
          },
          initialRoute:
              context.read<SettingsBloc>().state.model.isOnboardingCompleted
              ? authRepo.currentUser != null
                    ? context.read<SettingsBloc>().state.model.localAuthEnabled
                          ? LocalAuthScreen.routeName
                          : MainScreen.routeName
                    : LoginScreen.routeName
              : OnboardingScreen.routeName,
        );
      },
    );
  }
}
