import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import 'transaction_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const String routeName = '/category-detail';

  final Map<String, dynamic> category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Dummy expenses data
    final List<Map<String, dynamic>> expenses = [
      {'title': 'Grocery Run', 'date': 'Today', 'amount': 45.0},
      {'title': 'Dinner Out', 'date': 'Yesterday', 'amount': 60.0},
      {'title': 'Coffee', 'date': '2 days ago', 'amount': 15.0},
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          category['name'],
          style: const TextStyle(
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
              // Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Spent",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        Icon(category['icon'], color: category['color'], size: 28),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${category['amount'].toInt()}",
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "/ \$${category['budget'].toInt()}",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: category['amount'] / category['budget'],
                        backgroundColor: AppColors.primaryBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(category['color']),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Expenses List Header
              Text("Recent Expenses", style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),

              // Expenses List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      title: Text(expense['title'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(expense['date'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "-\$${expense['amount'].toInt()}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          TransactionDetailScreen.routeName,
                          arguments: {
                            ...expense,
                            'categoryName': category['name'],
                          },
                        );
                      },
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
}
