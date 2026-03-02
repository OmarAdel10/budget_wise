import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/model/transaction_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/colors.dart';
import '../../../../shared/constants/spacing.dart';
import '../../../../shared/constants/text_styles.dart';

class TransactionAmountHeader extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionAmountHeader({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = transaction.type == TransactionType.income;

    final bool hasLoggedIn = context.select<SettingsBloc, bool>(
      (settingsBloc) => settingsBloc.state.model.hasLoggedIn,
    );

    return Center(
      child: Column(
        children: [
          Text(
            isIncome ? l10n.amountReceived : l10n.amountSpent,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "${NumberFormat.currency(name: transaction.transactionCurrency).currencySymbol}${transaction.transactionAmount}",
            style: AppTextStyles.heading1.copyWith(
              color: isIncome ? AppColors.primaryAccent : AppColors.danger,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          hasLoggedIn
              ? AnimatedCrossFade(
                  firstChild: Shimmer.fromColors(
                    baseColor: AppColors.textSecondary,
                    highlightColor: Colors.grey.shade100,
                    enabled: true,
                    child: Text(
                      l10n.syncing,
                      style: AppTextStyles.bodyLarge.copyWith(
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  secondChild: Text(
                    l10n.synced,
                    style: AppTextStyles.bodyLarge.copyWith(
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  crossFadeState: !transaction.isSynced
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
