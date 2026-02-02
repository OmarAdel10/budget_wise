import 'dart:async';

import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/home/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
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
import 'add_transaction_screen.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'all_transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  bool _showIncome = false;

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
        final categoryData = state.model.categories.where((cat) {
          if (_showIncome) {
            return cat.category.type == TransactionType.income;
          } else {
            return cat.category.type == TransactionType.expense;
          }
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n.appTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false, // Hide back button
          ),
          body: Column(
            children: [
              //! Warning bar
              if (state.model.totalExpenses > state.model.totalIncome) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.warning(PhosphorIconsStyle.regular),
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.yourExpensesExceedYourIncome,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize:
                              context
                                      .read<SettingsBloc>()
                                      .state
                                      .model
                                      .language ==
                                  'en'
                              ? 13
                              : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(selectedMonth),
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
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: MediaQuery.sizeOf(context).height * 0.17,
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
                          final double backgroundOpacity = percentage.clamp(
                            0.0,
                            1.0,
                          );
                          return FlexibleSpaceBar(
                            centerTitle: true,
                            titlePadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 14,
                            ),
                            expandedTitleScale: 1.0,
                            background: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: backgroundOpacity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                child: Column(
                                  children: [
                                    //* Summary Cards
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                TransactionTypeDetailScreen
                                                    .routeName,
                                                arguments: {'type': 'income'},
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
                                                TransactionTypeDetailScreen
                                                    .routeName,
                                                arguments: {'type': 'outcome'},
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
                              ),
                            ),
                            title: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              opacity: opacity,
                              child: GestureDetector(
                                onTap: () {
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${l10n.income}: ',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${state.model.totalIncome.toStringAsFixed(0)}',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.primaryAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Text(
                                      '|',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Text(
                                      '${l10n.expenses}: ',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${state.model.totalExpenses.toStringAsFixed(0)}',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AllTransactionsScreen.routeName);
                                },
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
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showIncome = !_showIncome;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.cardBackground,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _showIncome
                                        ? '${l10n.income} '
                                        : '${l10n.expenses} ',
                                    style: TextStyle(
                                      color: _showIncome
                                          ? AppColors.primaryAccent
                                          : AppColors.expense,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _showIncome
                                        ? PhosphorIcons.arrowFatLinesUp(
                                            PhosphorIconsStyle.fill,
                                          )
                                        : PhosphorIcons.arrowFatLinesDown(
                                            PhosphorIconsStyle.fill,
                                          ),
                                    size: 16,
                                    color: _showIncome
                                        ? AppColors.primaryAccent
                                        : AppColors.expense,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.addCategory,
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
                        horizontal: AppSpacing.md,
                      ),
                      sliver: SliverReorderableList(
                        itemBuilder: (context, index) {
                          final categoryitem = categoryData[index];
                          final hasBudget =
                              categoryitem.category.hasBudgetAmount;
                          final budget =
                              categoryitem.category.budgetAmount ?? 0;
                          final spending = categoryitem.totalSpending;
                          final isIncome =
                              categoryitem.category.type ==
                              TransactionType.income;

                          double? progress;
                          if (hasBudget && budget > 0) {
                            progress = spending / budget;
                          }

                          return CategoryListItem(
                            key: ValueKey(categoryitem.category.id),
                            name: categoryitem.category.categoryTitle,
                            amount: spending.toStringAsFixed(0),
                            totalBudget: budget.toStringAsFixed(0),
                            hasBudgetAmount: hasBudget,
                            isIncome: isIncome,
                            icon: categoryitem.category.categoryIcon,
                            progress: progress,
                            index: index,
                            onDelete: () {
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final categoryBloc = context.read<CategoryBloc>();
                              final navigator = Navigator.of(context);

                              // Capture l10n strings before popping
                              final deletedMsg = l10n.transactionDeleted;
                              final undoLabel = l10n.undo;

                              // Pop immediately
                              if (navigator.canPop()) {
                                navigator.pop();
                              }

                              Timer? timer;
                              timer = Timer(const Duration(seconds: 3), () {
                                categoryBloc.add(
                                  CategoryEventDeleteCategory(
                                    categoryId: categoryitem.category.id,
                                  ),
                                );
                              });

                              scaffoldMessenger.clearSnackBars();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  dismissDirection: DismissDirection.horizontal,
                                  content: Text(deletedMsg),
                                  action: SnackBarAction(
                                    label: undoLabel,
                                    onPressed: () {
                                      timer?.cancel();
                                    },
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            onTap: () => Navigator.of(context).pushNamed(
                              CategoryDetailScreen.routeName,
                              arguments: {
                                'categoryId': categoryitem.category.id,
                                'progress': progress,
                              },
                            ),
                          );
                        },
                        itemCount: categoryData.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<CategoryBloc>().add(
                            CategoryEventReorder(
                              oldIndex: oldIndex,
                              newIndex: newIndex,
                            ),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl * 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "home_fab",
            tooltip: l10n.addTransactionTitle,
            onPressed: () =>
                Navigator.of(context).pushNamed(AddTransactionScreen.routeName),
            backgroundColor: AppColors.primaryAccent,
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
