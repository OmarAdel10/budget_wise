import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_wise/l10n/app_localizations.dart';

class MockHomeBloc extends Mock implements HomeBloc {}
class MockSettingsBloc extends Mock implements SettingsBloc {}
class MockTransactionBloc extends Mock implements TransactionBloc {}
class MockAccountBloc extends Mock implements AccountBloc {}

void main() {
  late MockHomeBloc mockHomeBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockTransactionBloc mockTransactionBloc;
  late MockAccountBloc mockAccountBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockTransactionBloc = MockTransactionBloc();
    mockAccountBloc = MockAccountBloc();

    final homeModel = HomeModel(
      totalIncome: 1000.0,
      totalExpenses: 500.0,
      currentMonth: DateTime(2026, 2),
      categories: const [],
      transactions: [
        TransactionModel(
          id: '1',
          userId: 'u1',
          accountId: 'a1',
          categoryId: 'c1',
          transactionAmount: 100.0,
          transactionDate: DateTime(2026, 2, 1),
          type: TransactionType.income,
          transactionTitle: 'Salary',
          transactionCurrency: 'EGP',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    );

    when(() => mockHomeBloc.state).thenReturn(HomeStateSuccess(model: homeModel));
    when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.value(HomeStateSuccess(model: homeModel)));

    when(() => mockSettingsBloc.state).thenReturn(const SettingsInitial(SettingsModel(), 'EGP'));
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockTransactionBloc.state).thenReturn(TransactionState.initial());
    when(() => mockTransactionBloc.stream).thenAnswer((_) => const Stream.empty());

    final now = DateTime.now();
    when(() => mockAccountBloc.state).thenReturn(AccountStateInitial(accountsList: [
      AccountModel(
        id: 'a1',
        title: 'Cash',
        balance: 1000,
        accountType: AccountType.cash,
        accountIcon: Icons.wallet,
        initialBalance: 1000,
        currency: 'EGP',
        createdAt: now,
        updatedAt: now,
      )
    ], netWorth: 1000.0));
    when(() => mockAccountBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
        BlocProvider<AccountBloc>.value(value: mockAccountBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: AllTransactionsScreen(),
      ),
    );
  }

  testWidgets('AllTransactionsScreen renders correctly with slivers', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(AllTransactionsScreen), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.textContaining('Income'), findsWidgets);
    expect(find.textContaining('Expenses'), findsWidgets);
  });
}
