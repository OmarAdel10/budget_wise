import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel model;
  const TransactionListItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          String accountTitle = l10n.noAccount;
          if (state.accountsList.isNotEmpty) {
            final account = state.accountsList.firstWhere(
              (a) => a.id == model.accountId,
              orElse: () => state.accountsList.first,
            );
            accountTitle = account.title;
          }
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            title: Text(
              model.transactionTitle,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "${DateFormat("dd/MM/yyyy").format(model.transactionDate)} • $accountTitle",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model.type == TransactionType.income
                      ? "+\$${model.transactionAmount}"
                      : "-\$${model.transactionAmount}",
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: model.type == TransactionType.income
                        ? AppColors.primaryAccent
                        : AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                TransactionDetailScreen.routeName,
                arguments: {'transModel': model},
              );
            },
          );
        },
      ),
    );
  }
}
