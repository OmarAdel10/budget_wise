import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/models/transaction_model.dart';
import '../../../../accounts/view_model/account_state.dart';
import '../../../../accounts/view_model/account_view_model.dart';
import '../../../../home/view_model/home_state.dart';
import '../../../../home/view_model/home_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/colors.dart';
import '../../../../shared/constants/spacing.dart';
import './transaction_detail_item.dart';

class TransactionInfoCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionInfoCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransactionDetailItem(
            icon: PhosphorIcons.tag(),
            label: l10n.title,
            value: transaction.transactionTitle,
          ),
          const Divider(color: AppColors.borderColor, height: AppSpacing.xl),
          TransactionDetailItem(
            icon: PhosphorIcons.calendar(),
            label: l10n.date,
            value: DateFormat(
              "dd/MM/yyyy | hh:mm",
            ).format(transaction.transactionDate),
          ),
          const Divider(color: AppColors.borderColor, height: AppSpacing.xl),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              final prevCat = previous.model.categories
                  .where((c) => c.source.financialId == transaction.categoryId)
                  .firstOrNull;
              final currCat = current.model.categories
                  .where((c) => c.source.financialId == transaction.categoryId)
                  .firstOrNull;
              return prevCat != currCat;
            },
            builder: (context, state) {
              final category = state.model.categories
                  .where((c) => c.source.financialId == transaction.categoryId)
                  .firstOrNull;

              return TransactionDetailItem(
                icon: PhosphorIcons.listBullets(),
                label: l10n.category,
                value: category?.source.financialTitle ?? l10n.noCategory,
              );
            },
          ),
          const Divider(color: AppColors.borderColor, height: AppSpacing.xl),
          BlocBuilder<AccountBloc, AccountState>(
            buildWhen: (previous, current) {
              final prevAcc = previous.accountsList
                  .where((a) => a.id == transaction.accountId)
                  .firstOrNull;
              final currAcc = current.accountsList
                  .where((a) => a.id == transaction.accountId)
                  .firstOrNull;
              return prevAcc != currAcc;
            },
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
              return TransactionDetailItem(
                icon: PhosphorIcons.bank(),
                label: l10n.account,
                value: accountTitle,
              );
            },
          ),
          if (transaction.transactionNotes != null &&
              transaction.transactionNotes!.isNotEmpty) ...[
            const Divider(color: AppColors.borderColor, height: AppSpacing.xl),
            TransactionDetailItem(
              icon: PhosphorIcons.note(),
              label: l10n.notes,
              value: transaction.transactionNotes!,
            ),
          ],
        ],
      ),
    );
  }
}
