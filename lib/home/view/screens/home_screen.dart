import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../../shared/widgets/category_list_item.dart';
import 'add_category_screen.dart';
import 'category_detail_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Dummy data for categories
    final List<Map<String, dynamic>> categories = [
      {
        'name': l10n.catSmoking,
        'amount': 100.0,
        'budget': 200.0,
        'icon': PhosphorIcons.fire(PhosphorIconsStyle.fill),
        'color': const Color(0xFFFF4081), // Pink
      },
      {
        'name': l10n.catEating,
        'amount': 300.0,
        'budget': 500.0,
        'icon': PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
        'color': const Color(0xFF009688), // Teal
      },
      {
        'name': l10n.catTransport,
        'amount': 200.0,
        'budget': 300.0,
        'icon': PhosphorIcons.car(PhosphorIconsStyle.fill),
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'name': l10n.catEntertainment,
        'amount': 150.0,
        'budget': 250.0,
        'icon': PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
        'color': const Color(0xFF9C27B0), // Purple
      },
      {
        'name': l10n.catUtils,
        'amount': 50.0,
        'budget': 100.0,
        'icon': PhosphorIcons.coffee(PhosphorIconsStyle.fill), // Using coffee for now or lightbulb
        'color': const Color(0xFFFFEB3B), // Yellow
      },
    ];

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
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.md),
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: l10n.income,
                                amount: "\$5,000",
                                amountColor: AppColors.primaryAccent,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SummaryCard(
                                title: l10n.outcome,
                                amount: "\$1,200",
                                amountColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Categories Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.categories,
                              style: AppTextStyles.heading3,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AddCategoryScreen.routeName);
                              },
                              icon: const Icon(
                                Icons.add,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ]),
                    )),

                // Category List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CategoryListItem(
                            name: category['name'],
                            amount: category['amount'].toInt().toString(),
                            totalBudget: category['budget'].toInt().toString(),
                            icon: category['icon'],
                            backgroundColor:
                                (category['color'] as Color).withOpacity(0.2),
                            iconColor: category['color'],
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                CategoryDetailScreen.routeName,
                                arguments: category,
                              );
                            },
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
          
          // New Expense Button (Custom Floating Action Button)
          Positioned(
            bottom: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Material(
              color: const Color(0xFFE57373), // Red accent for expense
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AddExpenseScreen.routeName);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.plus(PhosphorIconsStyle.bold),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.newExpense,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
