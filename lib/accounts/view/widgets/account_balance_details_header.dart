import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AccountBalanceDetailsHeader extends StatelessWidget {
  final double balance;
  final String currency;
  final DateTime? lastUpdatedAt;

  const AccountBalanceDetailsHeader({
    super.key,
    required this.balance,
    required this.currency,
    this.lastUpdatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            Text(
              '${NumberFormat.currency(name: currency).currencyName} ${balance.toStringAsFixed(2)}',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 42,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (lastUpdatedAt != null) ...[
              Text(
                '${l10n.lastUpdatedAt} ${timeago.format(lastUpdatedAt!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
