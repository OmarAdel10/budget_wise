import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import 'expense_detail_screen.dart';

class OutcomeDetailScreen extends StatelessWidget {
  static const String routeName = '/outcome-detail';

  const OutcomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy outcome data
    final List<Map<String, dynamic>> outcomeItems = [
      {'title': 'Grocery Store', 'date': 'Dec 02, 2025', 'amount': 150.0, 'categoryName': 'Food'},
      {'title': 'Petrol', 'date': 'Dec 05, 2025', 'amount': 60.0, 'categoryName': 'Transport'},
      {'title': 'Netflix Subscription', 'date': 'Dec 08, 2025', 'amount': 15.0, 'categoryName': 'Entertainment'},
      {'title': 'Electricity Bill', 'date': 'Dec 12, 2025', 'amount': 120.0, 'categoryName': 'Bills'},
      {'title': 'New Shoes', 'date': 'Dec 15, 2025', 'amount': 200.0, 'categoryName': 'Shopping'},
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
          "Outcome Details",
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
                      "Total Outcome (Dec)",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "\$1,200",
                      style: AppTextStyles.heading1.copyWith(color: AppColors.danger),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text("Transaction History", style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),

              // Outcome List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: outcomeItems.length,
                itemBuilder: (context, index) {
                  final item = outcomeItems[index];
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
                            "-\$${item['amount'].toInt()}",
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
