import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart';
import 'package:budget_wise/subscriptions/utils/subscription_formatter.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionSummaryHeader extends StatelessWidget {
  const SubscriptionSummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final totalMonthlySpend = context.select<SubscriptionBloc, double>(
      (bloc) => bloc.state.totalMonthlySpend,
    );
    
    final activeCount = context.select<SubscriptionBloc, int>(
      (bloc) => bloc.state.subscriptions.length,
    );
    
    final currencySymbol = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.model.defaultCurrency,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            SummaryCard(
              title: l10n.totalMonthlySpend,
              amount: SubscriptionFormatter.formatCurrency(
                totalMonthlySpend,
                currencySymbol,
              ),
              amountColor: AppColors.primaryAccent,
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  l10n.activeSubscriptions(activeCount),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
