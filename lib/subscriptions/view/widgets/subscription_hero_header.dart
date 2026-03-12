import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionHeroHeader extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final NumberFormat currencyFormat;

  const SubscriptionHeroHeader({
    super.key,
    required this.subscriptionModel,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              subscriptionModel.icon,
              color: AppColors.primaryAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subscriptionModel.name,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currencyFormat.format(subscriptionModel.amount),
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primaryAccent,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}
