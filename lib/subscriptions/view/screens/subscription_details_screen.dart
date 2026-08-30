import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_hero_header.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_info_grid.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_pay_action.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_bottom_sheet.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  static const routeName = '/subscription-details';

  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionId = ModalRoute.of(context)?.settings.arguments as String;
    final subscriptionModel = context
        .select<SubscriptionBloc, SubscriptionModel?>(
          (bloc) => bloc.state.subscriptions
              .where((sub) => sub.id == subscriptionId)
              .firstOrNull,
        );

    if (subscriptionModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotFoundDialog(context);
      });
      return const Scaffold();
    }

    final ValueNotifier<bool> isOverdueNotifier = ValueNotifier(
      BillingUtils.isOverdue(subscriptionModel.nextBillingDate),
    );
    final currencyFormat = subscriptionModel.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.subscriptionDetails),
        leading: CloseButton(),
        actions: [
          BlocSelector<SubscriptionBloc, SubscriptionState, SubscriptionModel>(
            selector: (state) =>
                state.subscriptions
                    .where((sub) => sub.id == subscriptionModel.id)
                    .firstOrNull ??
                subscriptionModel,
            builder: (context, model) {
              return IconButton(
                icon: const Icon(PhosphorIconsBold.pencil),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSubscriptionBottomSheet(subscriptionToEdit: model),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(PhosphorIconsBold.trash, color: AppColors.danger),
            onPressed: () =>
                _showDeleteDialog(context, subscriptionModel),
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
                  SubscriptionHeroHeader(subscriptionId: subscriptionModel.id),
                  const SizedBox(height: AppSpacing.xl),
                  SubscriptionInfoGrid(
                    subscriptionId: subscriptionModel.id,
                    isOverdueNotifier: isOverdueNotifier,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SubscriptionPayAction(
                    subscriptionModel: subscriptionModel,
                    isOverdueNotifier: isOverdueNotifier,
                  ),
                  Text(
                    context.l10n.paymentHistory,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          BlocSelector<
            TransactionBloc,
            TransactionState,
            List<TransactionModel>
          >(
            selector: (state) => state.getSubscriptionHistory(
              categoryId: subscriptionModel.categoryId,
              name: subscriptionModel.name,
            ),
            builder: (context, history) {
              if (history.isEmpty) {
                return SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                        horizontal: AppSpacing.md,
                      ),
                      child: Center(
                        child: Text(
                          context.l10n.noPaymentHistory,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return SubscriptionHistoryItem(
                      transaction: history[index],
                      currency: currencyFormat,
                    );
                  }, childCount: history.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(context.l10n.notAvailable, style: AppTextStyles.heading3),
        content: Text(
          context.l10n.thisSubscriptionNotAvailable,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          CustomButton(
            text: context.l10n.back,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteScheduledNotificationsForThisSubscription(
    SubscriptionModel model,
  ) async {
    final baseId = model.createdAt.millisecondsSinceEpoch ~/ 1000;
    for (int i = 0; i <= 31; i++) {
      await NotificationRepository.cancelNotificationById(baseId + i);
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    SubscriptionModel subscriptionModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => RepaintBoundary(
        child: AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            context.l10n.deleteSubscription,
            style: AppTextStyles.heading3,
          ),
          content: Text(
            context.l10n.deleteSubscriptionConfirm,
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel, style: AppTextStyles.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _deleteScheduledNotificationsForThisSubscription(
                  subscriptionModel,
                );
                context.read<SubscriptionBloc>().add(
                  SubscriptionDeleted(id: subscriptionModel.id),
                );
              },
              child: Text(
                context.l10n.deleteSubscription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
