import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_card.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubscriptionListScreen extends StatelessWidget {
  static const routeName = '/subscriptions';

  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptions), centerTitle: false),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading && state.subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.subscriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.noSubscriptions,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalMonthlySpend = state.subscriptions.fold<double>(0, (
            sum,
            sub,
          ) {
            if (sub.billingCycle == BillingCycle.yearly) {
              return sum + (sub.amount / 12);
            }
            return sum + sub.amount;
          });

          final currencyFormat = NumberFormat.simpleCurrency(name: 'EGP');

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAccent.withValues(alpha: 0.1),
                          AppColors.primaryBackground,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalMonthlySpend,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          currencyFormat.format(totalMonthlySpend),
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAccent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.activeSubscriptions(state.subscriptions.length),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subscription = state.subscriptions[index];
                    return SubscriptionCard(
                      subscription: subscription,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SubscriptionDetailsScreen.routeName,
                          arguments: {'subscriptionModel': subscription},
                        );
                      },
                    );
                  }, childCount: state.subscriptions.length),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ), // Space for FAB
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddSubscriptionScreen.routeName);
        },
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textInverse,
        child: const Icon(PhosphorIconsBold.plus, color: AppColors.textPrimary),
      ),
    );
  }
}
