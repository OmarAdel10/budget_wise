import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/data/repositories/category_repository.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/currency_conversions/data/repositories/currency_repository.dart';
import 'package:budget_wise/currency_conversions/view_model/currency_bloc.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/notifications/view_model/notification_bloc.dart';
import 'package:budget_wise/transaction/data/repositories/merchant_category_learning_repository.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_bloc.dart';
import 'package:budget_wise/buckets/data/repositories/saving_goal_repository.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/settings/data/repositories/settings_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/csv_export/service/csv_service.dart';
import 'package:budget_wise/csv_export/view_model/csv_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProviders {
  static Widget initProviders(
    Widget app,
    SharedPreferences prefs,
  ) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => AuthRepository()),
      RepositoryProvider(
        create: (context) => TransactionRepository(
          authRepository: context.read<AuthRepository>(),
        ),
      ),
      RepositoryProvider(
        create: (context) =>
            CategoryRepository(authRepository: context.read<AuthRepository>()),
      ),
      RepositoryProvider(
        create: (context) =>
            AccountRepository(authRepo: context.read<AuthRepository>()),
      ),
      RepositoryProvider(create: (context) => SettingsRepository()),
      RepositoryProvider(
        create: (context) => SavingGoalRepository(
          authRepo: context.read<AuthRepository>(),
          accountRepo: context.read<AccountRepository>(),
          transactionRepo: context.read<TransactionRepository>(),
        ),
      ),
      RepositoryProvider(
        create: (context) =>
            SubscriptionRepository(authRepo: context.read<AuthRepository>()),
      ),
      RepositoryProvider(create: (context) => CurrencyRepository(prefs)),
      RepositoryProvider(create: (context) => CsvService()),
      RepositoryProvider(
        create: (context) => MerchantCategoryLearningRepository(
          prefs: prefs,
          authRepository: context.read<AuthRepository>(),
        ),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotificationBloc()),
        BlocProvider(
          create: (context) => SettingsBloc(
            settingsRepository: context.read<SettingsRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            authRepository: context.read<AuthRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
            settingsBloc: context.read<SettingsBloc>(),
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => AccountBloc(
            settingsBloc: context.read<SettingsBloc>(),
            accountRepo: context.read<AccountRepository>(),
            authRepository: context.read<AuthRepository>(),
            transactionRepo: context.read<TransactionRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => BucketsBloc(
            settingsBloc: context.read<SettingsBloc>(),
            savingGoalRepo: context.read<SavingGoalRepository>(),
            authRepository: context.read<AuthRepository>(),
            accountBloc: context.read<AccountBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            settingsBloc: context.read<SettingsBloc>(),
            accountBloc: context.read<AccountBloc>(),
            categoryBloc: context.read<CategoryBloc>(),
            transactionRepository: context.read<TransactionRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (ctx) => HomeBloc(
            settingsBloc: ctx.read<SettingsBloc>(),
            transactionBloc: ctx.read<TransactionBloc>(),
            categoryBloc: ctx.read<CategoryBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => SubscriptionBloc(
            subscriptionRepository: context.read<SubscriptionRepository>(),
            authRepository: context.read<AuthRepository>(),
            settingsBloc: context.read<SettingsBloc>(),
            accountBloc: context.read<AccountBloc>(),
            transactionBloc: context.read<TransactionBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => CurrencyBloc(context.read<CurrencyRepository>()),
        ),
        BlocProvider(
          create: (context) => MerchantCategoryLearningBloc(
            repository: context.read<MerchantCategoryLearningRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => CsvBloc(
            csvService: CsvService(),
            transactionBloc: context.read<TransactionBloc>(),
            subscriptionBloc: context.read<SubscriptionBloc>(),
            savingsBloc: context.read<BucketsBloc>(),
          ),
        ),
      ],
      child: app,
    ),
  );
}
