import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionBloc extends Mock implements SubscriptionBloc {}
class MockTransactionBloc extends Mock implements TransactionBloc {}

void main() {
  late MockSubscriptionBloc mockSubscriptionBloc;
  late MockTransactionBloc mockTransactionBloc;

  final tSubscription = SubscriptionModel(
    id: '1',
    name: 'Netflix',
    amount: 100.0,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    categoryId: 'ent',
    icon: Icons.movie,
    startDate: DateTime.now(),
    billingDay: 1,
    nextBillingDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tTransaction = TransactionModel(
    id: 't1',
    type: TransactionType.expense,
    transactionTitle: 'Netflix',
    transactionAmount: 100.0,
    transactionCurrency: 'USD',
    transactionDate: DateTime.now(),
    categoryId: 'ent',
    accountId: 'acc1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockSubscriptionBloc = MockSubscriptionBloc();
    mockTransactionBloc = MockTransactionBloc();

    when(() => mockSubscriptionBloc.state).thenReturn(const SubscriptionInitial());
    when(() => mockSubscriptionBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTransactionBloc.state).thenReturn(
      TransactionState(transactionsList: [tTransaction]),
    );
    when(() => mockTransactionBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(
            arguments: {'subscriptionModel': tSubscription},
          ),
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<SubscriptionBloc>.value(value: mockSubscriptionBloc),
              BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
            ],
            child: const SubscriptionDetailsScreen(),
          ),
        );
      },
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            SubscriptionDetailsScreen.routeName,
          ),
          child: const Text('Go'),
        ),
      ),
    );
  }

  testWidgets('SubscriptionDetailsScreen renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsWidgets);
    expect(find.textContaining('100.0'), findsWidgets);
    expect(find.text('Payment History'), findsOneWidget);
  });
}
