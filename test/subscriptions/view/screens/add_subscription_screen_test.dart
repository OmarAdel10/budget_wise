import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_basic_info_fields.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionBloc extends Mock implements SubscriptionBloc {}
class MockCategoryBloc extends Mock implements CategoryBloc {}

void main() {
  late MockSubscriptionBloc mockSubscriptionBloc;
  late MockCategoryBloc mockCategoryBloc;

  final tCategory = CategoryModel(
    id: 'ent',
    categoryTitle: 'Entertainment',
    categoryIcon: Icons.movie,
    type: TransactionType.expense,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockSubscriptionBloc = MockSubscriptionBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockSubscriptionBloc.state).thenReturn(const SubscriptionInitial());
    when(() => mockSubscriptionBloc.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockCategoryBloc.state).thenReturn(
      CategoryStateInitial(categoriesList: [tCategory]),
    );
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SubscriptionBloc>.value(value: mockSubscriptionBloc),
          BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        ],
        child: const AddSubscriptionScreen(),
      ),
    );
  }

  testWidgets('AddSubscriptionScreen renders sliver layout and custom fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify CustomScrollView is used
    expect(find.byType(CustomScrollView), findsOneWidget);

    // Verify RepaintBoundaries are present (there should be several)
    expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(3));

    // Verify SubscriptionBasicInfoFields is present
    expect(find.byType(SubscriptionBasicInfoFields), findsOneWidget);

    // Verify localization (Add Subscription title)
    expect(find.text('Add Subscription'), findsOneWidget);
  });
}
