import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Summary Cards
    const double totalIncome = 5000.00;
    const double totalExpenses = 1200.00;
    const double currentSavings = 3800.00;

    // Dummy Data for Category Breakdown
    final List<Map<String, dynamic>> categorySpending = [
      {
        'name': 'Shopping',
        'amount': 500.0,
        'color': AppColors.categoryPink,
        'icon': PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill),
      },
      {
        'name': 'Food',
        'amount': 300.0,
        'color': AppColors.categoryTeal,
        'icon': PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
      },
      {
        'name': 'Transport',
        'amount': 200.0,
        'color': AppColors.categoryBlue,
        'icon': PhosphorIcons.car(PhosphorIconsStyle.fill),
      },
      {
        'name': 'Entertainment',
        'amount': 150.0,
        'color': AppColors.categoryPurple,
        'icon': PhosphorIcons.ticket(PhosphorIconsStyle.fill),
      },
      {
        'name': 'Utilities',
        'amount': 50.0,
        'color': AppColors.categoryYellow,
        'icon': PhosphorIcons.lightbulb(PhosphorIconsStyle.fill),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Financial Statistics",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard("Total Income", totalIncome, AppColors.income),
                  _buildSummaryCard("Total Expenses", totalExpenses, AppColors.expense),
                  _buildSummaryCard("Current Savings", currentSavings, AppColors.savings),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Spending by Category Section
              Text("Spending by Category", style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              
              // Category Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Category", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  Text("Amount", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Category List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categorySpending.length,
                itemBuilder: (context, index) {
                  final item = categorySpending[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item['color'].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'], color: item['color'], size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              item['name'],
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          "-\$${item['amount'].toInt()}",
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.expense),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "\$${amount.toStringAsFixed(0)}",
            style: AppTextStyles.heading3.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
