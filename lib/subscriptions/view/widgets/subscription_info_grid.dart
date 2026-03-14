import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubscriptionInfoGrid extends StatelessWidget {
  final String subscriptionId;
  final AppLocalizations l10n;
  final ValueNotifier<bool> isOverdueNotifier;

  const SubscriptionInfoGrid({
    super.key,
    required this.subscriptionId,
    required this.l10n,
    required this.isOverdueNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RepaintBoundary(
                child:
                    BlocSelector<
                      SubscriptionBloc,
                      SubscriptionState,
                      BillingCycle
                    >(
                      selector: (state) => state.subscriptions
                          .firstWhere(
                            (sub) => sub.id == subscriptionId,
                            orElse: () => state.subscriptions.first,
                          )
                          .billingCycle,
                      builder: (context, billingCycle) {
                        return SummaryCard(
                          title: l10n.billingCycle,
                          amount: billingCycle.label(l10n),
                          icon: Icons.calendar_today_outlined,
                          isCompact: true,
                          hasFixedHeight: true,
                          biggerHeightBy: 0.01,
                        );
                      },
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: RepaintBoundary(
                child:
                    BlocSelector<SubscriptionBloc, SubscriptionState, DateTime>(
                      selector: (state) => state.subscriptions
                          .firstWhere(
                            (sub) => sub.id == subscriptionId,
                            orElse: () => state.subscriptions.first,
                          )
                          .nextBillingDate,
                      builder: (context, nextBilling) {
                        return RepaintBoundary(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isOverdueNotifier,
                            builder: (context, isOverdue, child) {
                              return SummaryCard(
                                title: l10n.nextRenewalDate,
                                amount: DateFormat(
                                  'MMM dd, yyyy',
                                ).format(nextBilling),
                                icon: Icons.event_repeat_outlined,
                                amountColor: isOverdue
                                    ? AppColors.danger
                                    : null,
                                isCompact: true,
                                hasFixedHeight: true,
                                biggerHeightBy: 0.01,
                              );
                            },
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: RepaintBoundary(
                child: BlocSelector<SubscriptionBloc, SubscriptionState, bool>(
                  selector: (state) => state.subscriptions
                      .firstWhere(
                        (sub) => sub.id == subscriptionId,
                        orElse: () => state.subscriptions.first,
                      )
                      .reminderEnabled,
                  builder: (context, reminderEnabled) {
                    return RepaintBoundary(
                      child:
                          BlocSelector<
                            SubscriptionBloc,
                            SubscriptionState,
                            int
                          >(
                            selector: (state) => state.subscriptions
                                .firstWhere(
                                  (sub) => sub.id == subscriptionId,
                                  orElse: () => state.subscriptions.first,
                                )
                                .remindBeforeDays,
                            builder: (context, reminderValue) {
                              return SummaryCard(
                                title: l10n.reminder,
                                amount: reminderEnabled
                                    ? l10n.daysBefore(reminderValue)
                                    : l10n.off,
                                icon: Icons.notifications_active_outlined,
                                isCompact: true,
                                hasFixedHeight: true,
                                biggerHeightBy: 0.01,
                              );
                            },
                          ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: RepaintBoundary(
                child: BlocSelector<SubscriptionBloc, SubscriptionState, bool>(
                  selector: (state) => state.subscriptions
                      .firstWhere(
                        (sub) => sub.id == subscriptionId,
                        orElse: () => state.subscriptions.first,
                      )
                      .inActive,
                  builder: (context, isInActive) {
                    return RepaintBoundary(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isOverdueNotifier,
                        builder: (context, isOverdue, child) {
                          return SummaryCard(
                            title: l10n.status,
                            amount: (isInActive && isOverdue)
                                ? l10n.inActiveAndOverdue
                                : isInActive
                                ? l10n.inActive
                                : isOverdue
                                ? l10n.overdue
                                : l10n.active,
                            icon: (isInActive && isOverdue)
                                ? PhosphorIconsBold.xCircle
                                : isInActive
                                ? PhosphorIconsBold.pauseCircle
                                : isOverdue
                                ? PhosphorIconsBold.warningCircle
                                : PhosphorIconsBold.checkCircle,
                            amountColor: (isInActive && isOverdue)
                                ? AppColors.danger
                                : isInActive
                                ? Colors.orange
                                : isOverdue
                                ? AppColors.danger
                                : AppColors.primaryAccent,
                            isCompact: true,
                            hasFixedHeight: true,
                            biggerHeightBy: 0.01,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
