import 'package:budget_wise/subscriptions/view/widgets/subscription_hero_header.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_info_grid.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_pay_action.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  static const routeName = '/subscription-details';

  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final subscriptionModel = args?['subscriptionModel'] as SubscriptionModel;
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = BillingUtils.isOverdue(subscriptionModel.nextBillingDate);
    final currencyFormat = NumberFormat.simpleCurrency(
      name: subscriptionModel.currency,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddSubscriptionScreen.routeName,
                arguments: subscriptionModel,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () =>
                _showDeleteDialog(context, l10n, subscriptionModel.id),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubscriptionHeroHeader(
                    subscriptionModel: subscriptionModel,
                    currencyFormat: currencyFormat,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SubscriptionInfoGrid(
                    subscriptionModel: subscriptionModel,
                    l10n: l10n,
                    isOverdue: isOverdue,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SubscriptionPayAction(
                    subscriptionModel: subscriptionModel,
                    l10n: l10n,
                    isOverdue: isOverdue,
                  ),
                  Text(l10n.paymentHistory, style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          BlocSelector<TransactionBloc, TransactionState,
              List<TransactionModel>>(
            selector: (state) => state.getSubscriptionHistory(
              categoryId: subscriptionModel.categoryId,
              name: subscriptionModel.name,
            ),
            builder: (context, history) {
              if (history.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: AppSpacing.md,
                    ),
                    child: Center(
                      child: Text(
                        l10n.noPaymentHistory,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SubscriptionHistoryItem(
                        transaction: history[index],
                        formatter: currencyFormat,
                      );
                    },
                    childCount: history.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AppLocalizations l10n,
    String subscriptionId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(l10n.deleteSubscription, style: AppTextStyles.heading3),
        content: Text(
          l10n.deleteSubscriptionConfirm,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => context.read<SubscriptionBloc>().add(
                  SubscriptionDeleted(subscriptionId),
                ),
            child: Text(
              l10n.deleteSubscription,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
