import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/drag_handle.dart';
import 'package:budget_wise/shared/widgets/month_selector.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_summary_header.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_empty_state.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_header_card.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AllTransactionsBottomSheet extends StatefulWidget {
  final String initialTab;

  const AllTransactionsBottomSheet({super.key, this.initialTab = 'all'});

  static Future<void> show(BuildContext context, {String initialTab = 'all'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllTransactionsBottomSheet(initialTab: initialTab),
    );
  }

  @override
  State<AllTransactionsBottomSheet> createState() =>
      _AllTransactionsBottomSheetState();
}

class _AllTransactionsBottomSheetState
    extends State<AllTransactionsBottomSheet> {
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,
      initialChildSize: 0.85,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Column(
            children: [
              BottomSheetService.header(
                title: context.l10n.transactionHistory,
                isRoot: true,
                hasPadding: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    final model = state.model;
                    final currencySymbol = NumberFormat.currency(
                      name: context
                          .read<SettingsBloc>()
                          .state
                          .model
                          .defaultCurrency,
                    ).currencySymbol;

                    final filteredTransactions = _selectedTab == 'all'
                        ? model.transactions
                        : model.transactions
                              .where(
                                (t) =>
                                    t.type ==
                                    (_selectedTab == 'income'
                                        ? TransactionType.income
                                        : TransactionType.expense),
                              )
                              .toList();

                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: MonthSelector(
                            selectedMonth: model.currentMonth,
                            onPrevious: () => context.read<HomeBloc>().add(
                              HomeEventChangeMonth(
                                DateTime(
                                  model.currentMonth.year,
                                  model.currentMonth.month - 1,
                                ),
                              ),
                            ),
                            onNext: () => context.read<HomeBloc>().add(
                              HomeEventChangeMonth(
                                DateTime(
                                  model.currentMonth.year,
                                  model.currentMonth.month + 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: _buildTabBar(),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.md),
                        ),
                        SliverToBoxAdapter(
                          child: _buildSummary(
                            model.totalIncome,
                            model.totalExpenses,
                            currencySymbol,
                            model.currentMonth,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.lg),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          sliver: TransactionListView.sliver(
                            transactions: filteredTransactions,
                            emptyState: TransactionTypeEmptyState(
                              message: context.l10n.noTransactionsFound,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xxl),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('all', context.l10n.all),
      ('income', context.l10n.income),
      ('expense', context.l10n.expenses),
    ];

    return Row(
      children: tabs.map((tab) {
        final isSelected = _selectedTab == tab.$1;
        Color accentColor;
        switch (tab.$1) {
          case 'income':
            accentColor = AppColors.income;
          case 'expense':
            accentColor = AppColors.expense;
          default:
            accentColor = AppColors.primaryAccent;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.1)
                      : AppColors.cardBackground.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : AppColors.borderColor.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary(
    double totalIncome,
    double totalExpenses,
    String currencySymbol,
    DateTime currentMonth,
  ) {
    if (_selectedTab == 'all') {
      return TransactionSummaryHeader(
        income: totalIncome,
        expenses: totalExpenses,
        currencySymbol: currencySymbol,
      );
    }

    final isIncome = _selectedTab == 'income';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TransactionTypeHeaderCard(
        label:
            "${context.l10n.total} ${isIncome ? context.l10n.income : context.l10n.expenses} ${DateFormat('MMMM yyyy').format(currentMonth)}",
        amount: (isIncome ? totalIncome : totalExpenses).toString(),
        currencySymbol: currencySymbol,
        isIncome: isIncome,
      ),
    );
  }
}
