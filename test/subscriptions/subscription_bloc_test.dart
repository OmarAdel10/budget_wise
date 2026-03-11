import 'package:bloc_test/bloc_test.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSettingsBloc extends Mock implements SettingsBloc {}
class MockStorage extends Mock implements Storage {}

void main() {
  late SubscriptionBloc subscriptionBloc;
  late MockSubscriptionRepository mockSubscriptionRepository;
  late MockAuthRepository mockAuthRepository;
  late MockSettingsBloc mockSettingsBloc;
  late Storage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;

    mockSubscriptionRepository = MockSubscriptionRepository();
    mockAuthRepository = MockAuthRepository();
    mockSettingsBloc = MockSettingsBloc();

    final tSettingsState = SettingsInitial(const SettingsModel(), 'EGP');
    when(() => mockSettingsBloc.state).thenReturn(tSettingsState);
    when(() => mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());

    subscriptionBloc = SubscriptionBloc(
      subscriptionRepository: mockSubscriptionRepository,
      authRepository: mockAuthRepository,
      settingsBloc: mockSettingsBloc,
    );
  });

  tearDown(() {
    subscriptionBloc.close();
  });

  group('SubscriptionBloc Total Spend Calculation', () {
    final tSubscriptionMonthly = SubscriptionModel(
      id: '1',
      name: 'Netflix',
      amount: 100.0,
      currency: 'EGP',
      billingCycle: BillingCycle.monthly,
      categoryId: 'ent',
      icon: Icons.movie,
      startDate: DateTime.now(),
      billingDay: 1,
      nextBillingDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final tSubscriptionYearly = SubscriptionModel(
      id: '2',
      name: 'Amazon Prime',
      amount: 1200.0,
      currency: 'EGP',
      billingCycle: BillingCycle.yearly,
      categoryId: 'ent',
      icon: Icons.shop,
      startDate: DateTime.now(),
      billingDay: 1,
      nextBillingDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final tSubscriptionWeekly = SubscriptionModel(
      id: '3',
      name: 'Gym',
      amount: 10.0,
      currency: 'EGP',
      billingCycle: BillingCycle.weekly,
      categoryId: 'health',
      icon: Icons.fitness_center,
      startDate: DateTime.now(),
      billingDay: 1,
      nextBillingDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits state with correct totalMonthlySpend when subscriptions are added',
      build: () => subscriptionBloc,
      act: (bloc) => bloc.add(SubscriptionAdded(tSubscriptionMonthly)),
      verify: (bloc) {
        expect(bloc.state.totalMonthlySpend, 100.0);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'calculates total spend correctly for mixed billing cycles',
      build: () => subscriptionBloc,
      seed: () => SubscriptionLoadSuccess(
        subscriptions: [tSubscriptionMonthly],
        totalMonthlySpend: 100.0,
      ),
      act: (bloc) => bloc.add(SubscriptionAdded(tSubscriptionYearly)),
      verify: (bloc) {
        // 100 (monthly) + (1200 / 12) (yearly) = 200
        expect(bloc.state.totalMonthlySpend, 200.0);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'calculates weekly spend correctly (amount * 52 / 12)',
      build: () => subscriptionBloc,
      act: (bloc) => bloc.add(SubscriptionAdded(tSubscriptionWeekly)),
      verify: (bloc) {
        // 10 * 52 / 12 = 43.333333333333336
        expect(bloc.state.totalMonthlySpend, closeTo(43.33, 0.01));
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'ignores paused subscriptions in total spend calculation',
      build: () => subscriptionBloc,
      act: (bloc) => bloc.add(SubscriptionAdded(tSubscriptionMonthly.copyWith(isPaused: true))),
      verify: (bloc) {
        expect(bloc.state.totalMonthlySpend, 0.0);
      },
    );
  });
}
