import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionPayAction extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final AppLocalizations l10n;
  final bool isOverdue;

  const SubscriptionPayAction({
    super.key,
    required this.subscriptionModel,
    required this.l10n,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    if (!(isOverdue ||
        BillingUtils.daysUntil(
              subscriptionModel.nextBillingDate,
            ) <=
            7)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<SubscriptionBloc>().add(
                    SubscriptionPaid(subscriptionModel.id),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.markedAsPaid)),
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
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
              ),
            ),
            child: Text(l10n.payToRenew),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
