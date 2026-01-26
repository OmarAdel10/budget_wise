import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingGoalDetailScreen extends StatelessWidget {
  static const String routeName = '/saving-goal-detail';

  final Map<String, dynamic> goal;

  const SavingGoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    // Dummy Daily Savings Data
    final List<Map<String, dynamic>> dailySavings = List.generate(10, (index) {
      return {
        'day': index + 1,
        'amount': 50.0,
        'isCompleted': index < 5, // First 5 days completed
      };
    });

    final double progress = goal['currentAmount'] / goal['targetAmount'];
    final int percentage = (progress * 100).toInt();

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
          goal['name'],
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
              // Header Card with Progress
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
                          "Progress",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          "$percentage%",
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${goal['currentAmount'].toInt()}",
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "/ \$${goal['targetAmount'].toInt()}",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.primaryBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal['color'] ?? AppColors.primaryAccent,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Daily Savings Section
              Text("Daily Savings", style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Save small amounts daily to reach your goal.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Daily Savings List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailySavings.length,
                itemBuilder: (context, index) {
                  final saving = dailySavings[index];
                  final isCompleted = saving['isCompleted'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: isCompleted
                          ? Border.all(
                              color: AppColors.primaryAccent.withValues(
                                alpha: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${saving['day']}",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              "Day ${saving['day']}",
                              style: AppTextStyles.bodyLarge,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "\$${saving['amount'].toInt()}",
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              isCompleted
                                  ? PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.circle(
                                      PhosphorIconsStyle.regular,
                                    ),
                              color: isCompleted
                                  ? AppColors.primaryAccent
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                          ],
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
}
