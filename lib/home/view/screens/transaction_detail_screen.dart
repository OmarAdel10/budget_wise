import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart' show HomeBloc;
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_state.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:toastification/toastification.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const String routeName = '/transaction-detail';
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final transModel = args?['transModel'] as TransactionModel;
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final transaction =
            state.transactionsList
                .where((t) => t.id == transModel.id)
                .firstOrNull ??
            transModel;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              transaction.type == TransactionType.income
                  ? l10n.incomeDetails
                  : l10n.expenseDetails,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          transaction.type == TransactionType.income
                              ? l10n.amountReceived
                              : l10n.amountSpent,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "${NumberFormat.currency(name: transaction.transactionCurrency).currencySymbol}${transaction.transactionAmount}",
                          style: AppTextStyles.heading1.copyWith(
                            color: transaction.type == TransactionType.income
                                ? AppColors.primaryAccent
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Detail Info Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildDetailItem(
                          icon: PhosphorIcons.tag(),
                          label: l10n.title,
                          value: transaction.transactionTitle,
                        ),
                        const Divider(
                          color: AppColors.borderColor,
                          height: AppSpacing.xl,
                        ),
                        _buildDetailItem(
                          icon: PhosphorIcons.calendar(),
                          label: l10n.date,
                          value: DateFormat(
                            "dd/MM/yyyy | hh:mm",
                          ).format(transaction.transactionDate),
                        ),
                        const Divider(
                          color: AppColors.borderColor,
                          height: AppSpacing.xl,
                        ),
                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            final category = state.model.categories
                                .where(
                                  (c) =>
                                      c.category.id == transaction.categoryId,
                                )
                                .firstOrNull;

                            return _buildDetailItem(
                              icon: PhosphorIcons.listBullets(),
                              label: l10n.category,
                              value:
                                  category?.category.categoryTitle ??
                                  l10n.noCategory,
                            );
                          },
                        ),
                        const Divider(
                          color: AppColors.borderColor,
                          height: AppSpacing.xl,
                        ),
                        BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, state) {
                            String accountTitle = l10n.noAccount;
                            if (state.accountsList.isNotEmpty &&
                                transaction.accountId.isNotEmpty) {
                              final account = state.accountsList
                                  .where((a) => a.id == transaction.accountId)
                                  .firstOrNull;
                              if (account != null) {
                                accountTitle = account.title;
                              }
                            }
                            return _buildDetailItem(
                              icon: PhosphorIcons.bank(),
                              label: l10n.account,
                              value: accountTitle,
                            );
                          },
                        ),
                        if (transaction.transactionNotes != null &&
                            transaction.transactionNotes!.isNotEmpty) ...[
                          const Divider(
                            color: AppColors.borderColor,
                            height: AppSpacing.xl,
                          ),
                          _buildDetailItem(
                            icon: PhosphorIcons.note(),
                            label: l10n.notes,
                            value: transaction.transactionNotes!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                  transactionToEdit: transaction,
                                ),
                              ),
                            );
                          },
                          icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                          label: Text(l10n.edit),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            side: const BorderSide(
                              color: AppColors.textSecondary,
                            ),
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final transBloc = context.read<TransactionBloc>();

                            toastification.show(
                              context: context,
                              type: ToastificationType.warning,
                              style: ToastificationStyle.flatColored,
                              autoCloseDuration: const Duration(seconds: 3),
                              title: Text(l10n.transactionDeleted),
                              closeButton: ToastCloseButton(
                                showType: CloseButtonShowType.always,
                                buttonBuilder: (context, onClose) {
                                  return GestureDetector(
                                    onTap: onClose,
                                    child: Text(
                                      l10n.undo,
                                      style: AppTextStyles.button,
                                    ),
                                  );
                                },
                              ),
                              callbacks: ToastificationCallbacks(
                                onAutoCompleteCompleted: (item) {
                                  transBloc.add(
                                    TransactionEventDeleteTransaction(
                                      transactionId: transaction.id,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          icon: Icon(PhosphorIcons.trash(), size: 20),
                          label: Text(l10n.delete),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
