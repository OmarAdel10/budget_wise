import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/utils/subscription_formatter.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionHeroHeader extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionHeroHeader({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          RepaintBoundary(
            child: BlocSelector<SubscriptionBloc, SubscriptionState, int>(
              selector: (state) => state.subscriptions
                  .firstWhere(
                    (sub) => sub.id == subscriptionId,
                    orElse: () => state.subscriptions.first,
                  )
                  .iconColorValue,
              builder: (context, iconColorValue) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Color(iconColorValue).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      BlocSelector<
                        SubscriptionBloc,
                        SubscriptionState,
                        IconData
                      >(
                        selector: (state) => state.subscriptions
                            .firstWhere(
                              (sub) => sub.id == subscriptionId,
                              orElse: () => state.subscriptions.first,
                            )
                            .icon,
                        builder: (context, icon) {
                          return Icon(
                            icon,
                            color: Color(iconColorValue),
                            size: 48,
                          );
                        },
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RepaintBoundary(
            child: BlocSelector<SubscriptionBloc, SubscriptionState, String>(
              selector: (state) => state.subscriptions
                  .firstWhere(
                    (sub) => sub.id == subscriptionId,
                    orElse: () => state.subscriptions.first,
                  )
                  .name,
              builder: (context, name) {
                return Text(name, style: AppTextStyles.heading2);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          RepaintBoundary(
            child: BlocSelector<SubscriptionBloc, SubscriptionState, double>(
              selector: (state) => state.subscriptions
                  .firstWhere(
                    (sub) => sub.id == subscriptionId,
                    orElse: () => state.subscriptions.first,
                  )
                  .amount,
              builder: (context, amount) {
                return RepaintBoundary(
                  child:
                      BlocSelector<SubscriptionBloc, SubscriptionState, String>(
                        selector: (state) => state.subscriptions
                            .firstWhere(
                              (sub) => sub.id == subscriptionId,
                              orElse: () => state.subscriptions.first,
                            )
                            .currency,
                        builder: (context, currency) {
                          return Text(
                            SubscriptionFormatter.formatCurrency(
                              amount,
                              currency,
                            ),
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: 36,
                            ),
                          );
                        },
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
