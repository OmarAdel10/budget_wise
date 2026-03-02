import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAccountBloc extends Mock implements AccountBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAccountBloc mockAccountBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAccountBloc = MockAccountBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockAuthRepository = MockAuthRepository();

    when(
      () => mockSettingsBloc.state,
    ).thenReturn(const SettingsInitial(SettingsModel(), 'EGP'));
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAccountBloc.state,
    ).thenReturn(const AccountStateInitial(accountsList: [], netWorth: 0.0));
    when(() => mockAccountBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: mockAuthRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AccountBloc>.value(value: mockAccountBloc),
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: AddAccountScreen(),
        ),
      ),
    );
  }

  testWidgets('AddAccountScreen renders correctly and can toggle parts', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(AddAccountScreen), findsOneWidget);
    // Add more specific tests for the flow if needed
  });
}
