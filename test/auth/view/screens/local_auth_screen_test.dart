import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSettingsBloc = MockSettingsBloc();

    when(() => mockAuthBloc.state).thenReturn(const AuthStateInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    const settingsModel = SettingsModel(passcode: '1234', useBiometrics: true);
    when(
      () => mockSettingsBloc.state,
    ).thenReturn(const SettingsStateSuccess(settingsModel, 'EGP'));
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          MainScreen.routeName: (context) =>
              const Scaffold(body: Text('Main Screen')),
        },
        home: const LocalAuthScreen(),
      ),
    );
  }

  group('LocalAuthScreen Tests', () {
    testWidgets('renders LocalAuthScreen and shows enter passcode text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(LocalAuthScreen), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('enters correct passcode and navigates to MainScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap buttons 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));

      // Need to wait for the Navigator transition
      await tester.pumpAndSettle();

      expect(find.text('Main Screen'), findsOneWidget);
    });

    testWidgets('enters incorrect passcode and stays on screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap buttons 1, 1, 1, 1 (incorrect)
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));

      await tester.pumpAndSettle();

      expect(find.byType(LocalAuthScreen), findsOneWidget);
      expect(find.text('Main Screen'), findsNothing);

      // Wait for toast timer to finish
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
