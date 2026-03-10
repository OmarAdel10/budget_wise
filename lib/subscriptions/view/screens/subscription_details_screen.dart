import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  static const routeName = '/subscription-details';

  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final subscriptionModel = args?['subscriptionModel'] as SubscriptionModel;
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = BillingUtils.isOverdue(subscriptionModel.nextBillingDate);
    final currencyFormat = NumberFormat.simpleCurrency(
      name: subscriptionModel.currency,
    );

    String getCycleLabel(BillingCycle cycle) {
      switch (cycle) {
        case BillingCycle.weekly:
          return l10n.weekly;
        case BillingCycle.monthly:
          return l10n.monthly;
        case BillingCycle.quarterly:
          return l10n.quarterly;
        case BillingCycle.halfYearly:
          return l10n.halfYearly;
        case BillingCycle.yearly:
          return l10n.yearly;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddSubscriptionScreen.routeName,
                arguments: subscriptionModel,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () =>
                _showDeleteDialog(context, l10n, subscriptionModel.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      subscriptionModel.icon,
                      color: AppColors.primaryAccent,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(subscriptionModel.name, style: AppTextStyles.heading2),
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
            ),
            const SizedBox(height: AppSpacing.xl),

            // Info Cards Grid
            Row(
              children: [
                _buildInfoCard(
                  l10n.billingCycle,
                  getCycleLabel(subscriptionModel.billingCycle),
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildInfoCard(
                  l10n.nextRenewalDate,
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(subscriptionModel.nextBillingDate),
                  Icons.event_repeat_outlined,
                  valueColor: isOverdue ? AppColors.danger : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildInfoCard(
                  l10n.reminder,
                  subscriptionModel.reminderEnabled
                      ? l10n.daysBefore(subscriptionModel.remindBeforeDays)
                      : 'Off',
                  Icons.notifications_active_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildInfoCard(
                  'Status',
                  subscriptionModel.isPaused ? 'Paused' : 'Active',
                  subscriptionModel.isPaused
                      ? Icons.pause_circle_outline
                      : Icons.check_circle_outline,
                  valueColor: subscriptionModel.isPaused
                      ? Colors.orange
                      : AppColors.primaryAccent,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Pay Button
            if (isOverdue ||
                BillingUtils.daysUntil(subscriptionModel.nextBillingDate) <= 7)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SubscriptionBloc>().add(
                      SubscriptionPaid(subscriptionModel.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as paid!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(l10n.payToRenew),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            // Payment History (Filtered from Transactions)
            Text('Payment History', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                final history = state.transactionsList
                    .where(
                      (t) =>
                          t.categoryId == subscriptionModel.categoryId &&
                          t.transactionTitle.toLowerCase().contains(
                            subscriptionModel.name.toLowerCase(),
                          ),
                    )
                    .toList();

                if (history.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: Text(
                        'No payment history found.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: history
                      .map((t) => _buildHistoryItem(t, currencyFormat))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(dynamic transaction, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(transaction.transactionDate),
                style: AppTextStyles.bodyMedium,
              ),
              Text(transaction.accountId ?? '', style: AppTextStyles.bodySmall),
            ],
          ),
          Text(
            formatter.format(transaction.transactionAmount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AppLocalizations l10n,
    String subscriptionId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(l10n.deleteSubscription, style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete this subscription?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => context.read<SubscriptionBloc>().add(
              SubscriptionDeleted(subscriptionId),
            ),
            child: Text(
              l10n.deleteSubscription,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
