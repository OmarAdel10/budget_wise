import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SubscriptionPayAction extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final AppLocalizations l10n;
  final ValueNotifier<bool> isOverdueNotifier;

  const SubscriptionPayAction({
    super.key,
    required this.subscriptionModel,
    required this.l10n,
    required this.isOverdueNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isOverdueNotifier,
      builder: (context, isOverdue, child) {
        if (!isOverdue || subscriptionModel.inActive) {
          return const SizedBox.shrink();
        } else {
          return Column(
            children: [
              RepaintBoundary(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final transactionFromSubscriptionPaying =
                          TransactionModel(
                            type: TransactionType.expense,
                            transactionTitle: l10n.subPaying(
                              subscriptionModel.name,
                            ),
                            transactionAmount: subscriptionModel.amount,
                            transactionCurrency: subscriptionModel.currency,
                            categoryId: subscriptionModel.categoryId,
                            accountId: '',
                            transactionDate: DateTime.now(),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            transactionNotes: l10n.subNote(
                              subscriptionModel.name,
                              DateFormat(
                                'EEEE, dd MMMM yyyy',
                              ).format(DateTime.now()),
                            ),
                          );

                      context.read<SubscriptionBloc>().add(
                        SubscriptionPaid(subscriptionModel.id),
                      );

                      context.read<TransactionBloc>().add(
                        TransactionEventCreateTransaction(
                          transactionFromSubscriptionPaying,
                        ),
                      );
                      AppToast.show(
                        context,
                        title: l10n.markedAsPaid,
                        type: AppToastType.success,
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
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        }
      },
    );
  }
}
