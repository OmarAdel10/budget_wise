import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/data/repositories/savings_repository.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/data/repositories/category_repository.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_view_model.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/settings/view/screens/passcode_setup_screen.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_screen.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:budget_wise/shared/app_theme.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/category/view/screens/add_category_screen.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/savings/view/screens/add_saving_goal_screen.dart';
import 'package:budget_wise/savings/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/transaction/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/transaction/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

import 'package:budget_wise/savings/view/screens/edit_saving_goal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(
          create: (context) => TransactionRepository(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => CategoryRepository(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              AccountRepository(authRepo: context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              SavingsRepository(authRepo: context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              SubscriptionRepository(authRepo: context.read<AuthRepository>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(create: (context) => SettingsBloc()),
          BlocProvider(
            create: (context) => AccountBloc(
              settingsBloc: context.read<SettingsBloc>(),
              accountRepo: context.read<AccountRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SavingsBloc(
              settingsBloc: context.read<SettingsBloc>(),
              savingsRepo: context.read<SavingsRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TransactionBloc(
              settingsBloc: context.read<SettingsBloc>(),
              accountBloc: context.read<AccountBloc>(),
              transactionRepository: context.read<TransactionRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              authRepository: context.read<AuthRepository>(),
              categoryRepository: context.read<CategoryRepository>(),
              settingsBloc: context.read<SettingsBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => HomeBloc(
              categoryBloc: context.read<CategoryBloc>(),
              settingsBloc: context.read<SettingsBloc>(),
              transactionBloc: context.read<TransactionBloc>(),
              categoryRepository: context.read<CategoryRepository>(),
              transactionRepository: context.read<TransactionRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SubscriptionBloc(
              subscriptionRepository: context.read<SubscriptionRepository>(),
              authRepository: context.read<AuthRepository>(),
              settingsBloc: context.read<SettingsBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => StatisticsBloc(
              transactionBloc: context.read<TransactionBloc>(),
              categoryBloc: context.read<CategoryBloc>(),
              savingsBloc: context.read<SavingsBloc>(),
              subscriptionBloc: context.read<SubscriptionBloc>(),
            )..add(StatisticsEventLoadRequested(DateTime.now())),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
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
                  reverseType: PageTransitionType.topToBottom,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddCategoryScreen(),
                );
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
              case AddTransactionScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.bottomToTop,
                  reverseType: PageTransitionType.topToBottom,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddTransactionScreen(),
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
              case SavingGoalDetailScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  reverseType: PageTransitionType.leftToRight,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: SavingGoalDetailScreen(),
                );
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
              case LocalAuthScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.fade,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const LocalAuthScreen(),
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
              case AddSubscriptionScreen.routeName:
                return PageTransition(
                  type: PageTransitionType.bottomToTop,
                  reverseType: PageTransitionType.topToBottom,
                  ctx: context,
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: const AddSubscriptionScreen(),
                );
              default:
                return null;
            }
          },
          initialRoute:
              context.read<SettingsBloc>().state.model.isOnboardingCompleted
              ? context.read<SettingsBloc>().state.model.localAuthEnabled
                    ? LocalAuthScreen.routeName
                    : MainScreen.routeName
              : OnboardingScreen.routeName,
        );
      },
    );
  }
}
