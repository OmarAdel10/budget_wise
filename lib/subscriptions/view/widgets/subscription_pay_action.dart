import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/currency_conversions/view/currency_conversion_preview.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubscriptionPayAction extends StatefulWidget {
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
  State<SubscriptionPayAction> createState() => _SubscriptionPayActionState();
}

class _SubscriptionPayActionState extends State<SubscriptionPayAction> {
  double? _convertedAmount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isOverdueNotifier,
      builder: (context, isOverdue, child) {
        if (!isOverdue || widget.subscriptionModel.inActive) {
          return const SizedBox.shrink();
        } else {
          final account = context
              .read<AccountBloc>()
              .state
              .accountsList
              .firstWhere((a) => a.id == widget.subscriptionModel.accountId);
          final hasCurrencyMismatch =
              account.currency != widget.subscriptionModel.currency;

          return Column(
            children: [
              if (hasCurrencyMismatch) ...[
                CurrencyConversionPreview(
                  amount: widget.subscriptionModel.amount,
                  fromCurrency: widget.subscriptionModel.currency,
                  toCurrency: account.currency,
                  onConvertedAmountChanged: (val) {
                    _convertedAmount = val;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              RepaintBoundary(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final subscriptionBloc = context.read<SubscriptionBloc>();

                      subscriptionBloc.add(
                        SubscriptionPaid(
                          widget.subscriptionModel.id,
                          convertedAmount: _convertedAmount,
                          l10n: widget.l10n,
                          toastCallback: () {
                            AppToast.show(
                              context,
                              title: widget.l10n.budgetLimitExceeded,
                              type: AppToastType.warning,
                            );
                          },
                        ),
                      );

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSpacing.radiusLg),
                              topRight: Radius.circular(AppSpacing.radiusLg),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.fill,
                                ),
                                color: AppColors.success,
                                size: 80,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                widget.l10n.markedAsPaid,
                                style: AppTextStyles.heading3,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close sheet
                                    Navigator.pop(context); // Close detail screen
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
                                  child: Text(widget.l10n.continueWord),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
                    child: Text(widget.l10n.payToRenew),
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
