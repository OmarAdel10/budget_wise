import 'package:budget_wise/home/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/home/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../../shared/widgets/category_list_item.dart';
import 'add_category_screen.dart';
import 'category_detail_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeEventLoadAllData(selectedMonth));
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final recentTransactions = state.model.transactions.take(5).toList();
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "BudgetWise",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false, // Hide back button
          ),
          body: Column(
            children: [
              //! Month Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _monthChange(-1),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat("MMM yyyy").format(selectedMonth),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _monthChange(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverAppBar(
                        pinned: true,
                        // floating: true,
                        expandedHeight:
                            MediaQuery.sizeOf(context).height * 0.17,
                        backgroundColor: AppColors.primaryBackground,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final double percentage =
                                (constraints.biggest.height - kToolbarHeight) /
                                ((MediaQuery.sizeOf(context).height * 0.17) -
                                    kToolbarHeight);
                            // percentage goes from 1.0 (expanded) to 0.0 (collapsed)
                            // We want opacity to be 1.0 when collapsed (percentage -> 0)
                            // and 0.0 when expanded (percentage -> 1)
                            final double opacity = (1.0 - percentage).clamp(
                              0.0,
                              1.0,
                            );
                            return FlexibleSpaceBar(
                              centerTitle: true,
                              titlePadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: 16,
                              ),
                              expandedTitleScale: 1.0,
                              background: Column(
                                children: [
                                  //* Summary Cards
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              TransactionTypeDetailScreen.routeName,
                                              arguments: {
                                                'type': 'income',
                                              },
                                            );
                                          },
                                          child: SummaryCard(
                                            title: l10n.income,
                                            amount:
                                                "\$${state.model.totalIncome.toStringAsFixed(0)}",
                                            amountColor:
                                                AppColors.primaryAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              TransactionTypeDetailScreen.routeName,
                                              arguments: {
                                                'type': 'outcome',
                                              },
                                            );
                                          },
                                          child: SummaryCard(
                                            title: l10n.expenses,
                                            amount:
                                                "\$${state.model.totalExpenses.toStringAsFixed(0)}",
                                            amountColor: AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              title: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                opacity: opacity,
                                child: GestureDetector(
                                  onTap: () {
                                    _scrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${l10n.income}: ',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            '\$${state.model.totalIncome.toStringAsFixed(0)}',
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  color:
                                                      AppColors.primaryAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '|',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${l10n.expenses}: ',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            '\$${state.model.totalExpenses.toStringAsFixed(0)}',
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  color: AppColors.danger,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (state.model.transactions.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.recentTransactions,
                                style: AppTextStyles.heading3,
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  l10n.seeAll,
                                  style: AppTextStyles.link,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sm),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final isLast =
                                index == recentTransactions.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 0 : AppSpacing.sm,
                              ),
                              child: TransactionListItem(
                                model: recentTransactions[index],
                              ),
                            );
                          }, childCount: recentTransactions.length),
                        ),
                      ),
                    ],
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.categories,
                              style: AppTextStyles.heading3,
                            ),
                            IconButton(
                              tooltip: 'Add Category',
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AddCategoryScreen.routeName);
                              },
                              icon: Icon(
                                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final categoryData = state.model.categories[index];
                          final hasBudget =
                              categoryData.category.hasBudgetAmount;
                          final budget =
                              categoryData.category.budgetAmount ?? 0;
                          final spending = categoryData.totalSpending;

                          double? progress;
                          if (hasBudget && budget > 0) {
                            progress = spending / budget;
                          }

                          final isLast =
                              index == state.model.categories.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isLast ? 0 : AppSpacing.sm,
                            ),
                            child: CategoryListItem(
                              name: categoryData.category.categoryTitle,
                              amount: spending.toStringAsFixed(0),
                              totalBudget: budget.toStringAsFixed(0),
                              hasBudgetAmount: hasBudget,
                              icon: categoryData.category.categoryIcon,
                              progress: progress,
                              onTap: () => Navigator.of(context).pushNamed(
                                CategoryDetailScreen.routeName,
                                arguments: categoryData,
                              ),
                            ),
                          );
                        }, childCount: state.model.categories.length),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add Expense',
            onPressed: () =>
                Navigator.of(context).pushNamed(AddExpenseScreen.routeName),
            backgroundColor: const Color(0xFFE57373),
            child: Icon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
