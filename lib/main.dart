import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view/screens/login_screen.dart';
import 'package:budget_wise/auth/view/screens/signup_screen.dart';
import 'package:budget_wise/auth/view/screens/forgot_password_screen.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/data/repositories/category_repository.dart';
import 'package:budget_wise/home/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_view_model.dart';
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
import 'package:budget_wise/home/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/savings/view/screens/add_saving_goal_screen.dart';
import 'package:budget_wise/savings/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/home/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/home/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/home/view/screens/all_transactions_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
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
            )..add(AccountEventFetchAll()),
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
            create: (context) => StatisticsBloc(
              transactionBloc: context.read<TransactionBloc>(),
              categoryBloc: context.read<CategoryBloc>(),
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
                final args = settings.arguments as Map<String, dynamic>;
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  reverseType: PageTransitionType.leftToRight,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: SavingGoalDetailScreen(goal: args),
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
                final args = settings.arguments as TransactionModel;
                return PageTransition(
                  type: PageTransitionType.rightToLeft,
                  reverseType: PageTransitionType.leftToRight,
                  ctx: context,
                  duration: Duration(milliseconds: 500),
                  reverseDuration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  settings: settings,
                  child: TransactionDetailScreen(transModel: args),
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
              default:
                return null;
            }
          },
          initialRoute:
              context.read<SettingsBloc>().state.model.isOnboardingCompleted
              ? context.read<AuthRepository>().currentUser != null
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
