import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
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
      (bloc) => bloc.state.subscriptions.where((sub) => sub.inActive == false).length,
    );

    final inActiveCount = context.select<SubscriptionBloc, int>(
      (bloc) => bloc.state.subscriptions.where((sub) => sub.inActive).length,
    );

    final overdueCount = context.select<SubscriptionBloc, int>(
      (bloc) => bloc.state.subscriptions
          .where((sub) => BillingUtils.isOverdue(sub.nextBillingDate))
          .length,
    );

    final currencySymbol = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.currencySymbol,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: SummaryCard.subscriptions(
                title: l10n.totalMonthlySpend,
                amount: SubscriptionFormatter.formatCurrency(
                  totalMonthlySpend,
                  currencySymbol,
                ),
                amountColor: AppColors.primaryAccent,
                thirdWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Divider(color: AppColors.borderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              activeCount.toString(),
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                            Text(
                              l10n.active,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 45,
                          child: const VerticalDivider(
                            color: AppColors.borderColor,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              inActiveCount.toString(),
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              l10n.inActive,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 45,
                          child: const VerticalDivider(
                            color: AppColors.borderColor,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              overdueCount.toString(),
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                            Text(
                              l10n.overdue,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
