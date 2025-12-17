import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import 'expense_detail_screen.dart';

class IncomeDetailScreen extends StatelessWidget {
  static const String routeName = '/income-detail';

  const IncomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy income data
    final List<Map<String, dynamic>> incomeItems = [
      {'title': 'Monthly Salary', 'date': 'Dec 01, 2025', 'amount': 4000.0, 'categoryName': 'Salary'},
      {'title': 'Freelance Project', 'date': 'Dec 10, 2025', 'amount': 800.0, 'categoryName': 'Freelance'},
      {'title': 'Dividends', 'date': 'Dec 15, 2025', 'amount': 200.0, 'categoryName': 'Investment'},
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
        title: const Text(
          "Income Details",
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
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Income (Dec)",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "\$5,000",
                      style: AppTextStyles.heading1.copyWith(color: AppColors.primaryAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text("Transaction History", style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),

              // Income List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incomeItems.length,
                itemBuilder: (context, index) {
                  final item = incomeItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      title: Text(item['title'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(item['date'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "+\$${item['amount'].toInt()}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ExpenseDetailScreen.routeName,
                          arguments: item,
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
