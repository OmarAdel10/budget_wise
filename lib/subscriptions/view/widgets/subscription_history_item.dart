import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/utils/subscription_formatter.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionHistoryItem extends StatelessWidget {
  final TransactionModel transaction;
  final String currency;

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  const SubscriptionHistoryItem({
    super.key,
    required this.transaction,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddTransactionBottomSheet(
          transactionToEdit: transaction,
        ),
      ),
      child: Container(
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
                  _dateFormat.format(transaction.transactionDate),
                  style: AppTextStyles.bodyMedium,
                ),
                Text(transaction.accountId, style: AppTextStyles.bodySmall),
              ],
            ),
            Text(
              SubscriptionFormatter.formatCurrency(
                transaction.transactionAmount,
                currency,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
