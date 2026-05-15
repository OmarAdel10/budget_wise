import 'package:budget_wise/sst/view/widgets/morphing_fab_recorder.dart';
import 'package:budget_wise/settings/data/models/transaction_input_mode.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/income_expense_toggle.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/home/view/widgets/home_app_bar.dart';
import 'package:budget_wise/home/view/widgets/home_categories_section.dart';
import 'package:budget_wise/home/view/widgets/home_flexible_header.dart';
import 'package:budget_wise/home/view/widgets/home_recent_transactions.dart';
import 'package:budget_wise/home/view/widgets/home_warning_bar.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/widgets/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../settings/view_model/settings_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<ToggleOption> _showIncomeNotifier;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeEventLoadAllData(selectedMonth));
    _showIncomeNotifier = ValueNotifier<ToggleOption>(ToggleOption.expense);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showIncomeNotifier.dispose();
    super.dispose();
  }

  void _monthChange(int month) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + month);
    });
    context.read<HomeBloc>().add(HomeEventLoadAllData(selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    final isVoiceMode =
        settingsState.model.transactionInputMode == TransactionInputMode.voice;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          const HomeWarningBar(),
          MonthSelector(
            selectedMonth: selectedMonth,
            onPrevious: () => _monthChange(-1),
            onNext: () => _monthChange(1),
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
                HomeFlexibleHeader(scrollController: _scrollController),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IncomeExpenseToggle(
                          selectionNotifier: _showIncomeNotifier,
                        ),
                      ],
                    ),
                  ),
                ),
                const HomeRecentTransactions(),
                HomeCategoriesSection(showIncomeNotifier: _showIncomeNotifier),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl * 2),
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: isVoiceMode
          // ? const MorphingFabRecorder()
          floatingActionButton:  FloatingActionButton(
              heroTag: "home_fab",
              tooltip: l10n.addTransactionTitle,
              onPressed: () {
                Navigator.of(context).pushNamed(AddTransactionScreen.routeName);
              },
              backgroundColor: AppColors.primaryAccent,
              child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
            ),
    );
  }
}
