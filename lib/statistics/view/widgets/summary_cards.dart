import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart' as shared;
import 'package:budget_wise/transaction/view/widgets/all_transactions_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';

class SummaryCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double totalSubscriptions;

  const SummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = NumberFormat.currency(
      name: context.read<SettingsBloc>().state.model.defaultCurrency,
    ).currencySymbol;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: shared.SummaryCard(
                isCompact: true,
                title: context.l10n.totalIncome,
                amount: "$currencySymbol ${totalIncome.toStringAsFixed(0)}",
                amountColor: AppColors.income,
                onTap: () {
                  AllTransactionsBottomSheet.show(
                    context,
                    initialTab: 'income',
                  );
                },
                hasFixedHeight: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: shared.SummaryCard(
                isCompact: true,
                title: context.l10n.totalExpenses,
                amount: "$currencySymbol ${totalExpenses.toStringAsFixed(0)}",
                amountColor: AppColors.expense,
                onTap: () {
                  AllTransactionsBottomSheet.show(
                    context,
                    initialTab: 'expense',
                  );
                },
                hasFixedHeight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: shared.SummaryCard(
                isCompact: true,
                title: context.l10n.currentSavings,
                amount: "$currencySymbol ${totalSavings.toStringAsFixed(0)}",
                amountColor: AppColors.savings,
                hasFixedHeight: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: shared.SummaryCard(
                isCompact: true,
                title: context.l10n.totalSubscriptions,
                amount:
                    "$currencySymbol ${totalSubscriptions.toStringAsFixed(0)}",
                amountColor: AppColors.subscription,
                hasFixedHeight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
