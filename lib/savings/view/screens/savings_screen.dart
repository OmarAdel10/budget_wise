import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

import 'add_saving_goal_screen.dart';
import 'saving_goal_detail_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Dummy Data
    final List<Map<String, dynamic>> savingGoals = [
      {
        'name': 'New Car',
        'currentAmount': 5000.0,
        'targetAmount': 20000.0,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'name': 'Vacation',
        'currentAmount': 1500.0,
        'targetAmount': 5000.0,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'name': 'Emergency Fund',
        'currentAmount': 10000.0,
        'targetAmount': 15000.0,
        'color': const Color(0xFFFFC107), // Amber
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.navSavings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: savingGoals.length,
                itemBuilder: (context, index) {
                  final goal = savingGoals[index];
                  final double progress =
                      goal['currentAmount'] / goal['targetAmount'];
                  final int percentage = (progress * 100).toInt();

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        SavingGoalDetailScreen.routeName,
                        arguments: goal,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(goal['name'], style: AppTextStyles.heading3),
                              Text(
                                "$percentage%",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Text(
                                "\$${goal['currentAmount'].toInt()}",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " / \$${goal['targetAmount'].toInt()}",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.primaryBackground,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                goal['color'],
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "savings_fab",
        onPressed: () {
          Navigator.of(context).pushNamed(AddSavingGoalScreen.routeName);
        },
        backgroundColor: AppColors.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
