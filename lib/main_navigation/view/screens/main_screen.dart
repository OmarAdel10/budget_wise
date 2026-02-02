import 'dart:async';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/view/screens/home_screen.dart';
import '../../../accounts/view/screens/accounts_screen.dart';
import '../../../savings/view/screens/savings_screen.dart';
import '../../../statistics/view/screens/statistics_screen.dart';
import '../../../settings/view/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime _lastSyncTime = DateTime.now();
  final Duration _syncInterval = const Duration(minutes: 15);
  Timer? _periodicCheckTimer;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AccountsScreen(),
    const SavingsScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performInitialSync();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicCheck();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSyncIfNecessary();
      _startPeriodicCheck();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopPeriodicCheck();
    }
  }

  void _performInitialSync() {
    if (context.read<SettingsBloc>().state.model.hasLoggedIn &&
        context.read<AuthRepository>().currentUser != null) {
      context.read<TransactionBloc>().add(
        const TransactionEventCheckAndSyncPending(),
      );
      context.read<CategoryBloc>().add(
        const CategoryEventCheckAndSyncPending(),
      );
      context.read<AccountBloc>().add(const AccountEventCheckAndSyncPending());
    }
  }

  void _triggerSyncIfNecessary() {
    final now = DateTime.now();
    if (now.difference(_lastSyncTime) >= _syncInterval) {
      _performSync();
      _lastSyncTime = now;
    }
  }

  void _performSync() {
    if (context.read<AuthRepository>().currentUser != null) {
      context.read<TransactionBloc>().add(
        const TransactionEventCheckAndSyncPending(),
      );
      context.read<CategoryBloc>().add(
        const CategoryEventCheckAndSyncPending(),
      );
      context.read<AccountBloc>().add(const AccountEventCheckAndSyncPending());
    }
  }

  void _startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _triggerSyncIfNecessary();
    });
  }

  void _stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
