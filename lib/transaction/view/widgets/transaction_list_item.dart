import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel model;
  final VoidCallback? onDelete;
  final bool hasBG;

  const TransactionListItem({
    super.key,
    required this.model,
    this.onDelete,
    this.hasBG = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bool hasLoggedIn = context.select<SettingsBloc, bool>(
      (settingsBloc) => settingsBloc.state.model.hasLoggedIn,
    );

    final accountTitle = context.select<AccountBloc, String>((accBloc) {
      final account = accBloc.state.accountsList
          .where((a) => a.id == model.accountId)
          .firstOrNull;
      return account?.title ?? l10n.noAccount;
    });

    Widget content = Container(
      decoration: BoxDecoration(
        color: hasBG ? AppColors.cardBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: !hasBG ? Border.all(color: AppColors.borderColor) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          model.transactionTitle,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${DateFormat("dd/MM/yyyy").format(model.transactionDate)} • ${accountTitle.isEmpty ? l10n.noAccount : accountTitle}",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            hasLoggedIn
                ? AnimatedCrossFade(
                    firstChild: Shimmer.fromColors(
                      baseColor: AppColors.textSecondary,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Text(
                        l10n.syncing,
                        style: AppTextStyles.bodySmall.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    secondChild: Text(
                      l10n.synced,
                      style: AppTextStyles.bodySmall.copyWith(letterSpacing: 2),
                    ),
                    crossFadeState: !model.isSynced
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.type == TransactionType.income
                  ? "+${NumberFormat.currency(name: model.transactionCurrency).currencySymbol}${model.transactionAmount}"
                  : "-${NumberFormat.currency(name: model.transactionCurrency).currencySymbol}${model.transactionAmount}",
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
      ),
    );

    if (onDelete != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Slidable(
          key: ValueKey(model.id),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) => onDelete?.call(),
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.trash(PhosphorIconsStyle.bold),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ],
          ),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: content,
    );
  }
}
