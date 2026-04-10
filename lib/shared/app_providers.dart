import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/data/repositories/category_repository.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/savings/data/repositories/savings_repository.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/settings/data/repositories/settings_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/statistics/view_model/statistics_event.dart';
import 'package:budget_wise/statistics/view_model/statistics_view_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppProviders {
  static Widget initProviders(Widget app) => MultiRepositoryProvider(
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
        create: (context) => AccountRepository(
          authRepo: context.read<AuthRepository>(),
        ),
      ),
      RepositoryProvider(create: (context) => SettingsRepository()),
      RepositoryProvider(
        create: (context) => SavingsRepository(
          authRepo: context.read<AuthRepository>(),
          accountRepo: context.read<AccountRepository>(),
          transactionRepo: context.read<TransactionRepository>(),
        ),
      ),
      RepositoryProvider(
        create: (context) =>
            SubscriptionRepository(authRepo: context.read<AuthRepository>()),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
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
          create: (context) => AccountBloc(
            settingsBloc: context.read<SettingsBloc>(),
            accountRepo: context.read<AccountRepository>(),
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
          create: (context) => SavingsBloc(
            settingsBloc: context.read<SettingsBloc>(),
            savingsRepo: context.read<SavingsRepository>(),
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
          )..add(const TransactionEventLoadBackgroundDrafts()),
        ),
        BlocProvider(
          create: (context) => SubscriptionBloc(
            subscriptionRepository: context.read<SubscriptionRepository>(),
            authRepository: context.read<AuthRepository>(),
            settingsBloc: context.read<SettingsBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            categoryBloc: context.read<CategoryBloc>(),
            settingsBloc: context.read<SettingsBloc>(),
            transactionBloc: context.read<TransactionBloc>(),
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
      child: app,
    ),
  );
}
