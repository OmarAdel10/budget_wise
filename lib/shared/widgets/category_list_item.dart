import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';
import 'generic_icon_container.dart';

class CategoryListItem extends StatelessWidget {
  final String name;
  final double totalSpent;
  final int totalNumberOfTransaction;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final TransactionType type;
  final bool isOverBudget;

  const CategoryListItem({
    super.key,
    required this.name,
    required this.totalSpent,
    required this.totalNumberOfTransaction,
    required this.icon,
    required this.onTap,
    this.onDelete,
    this.type = TransactionType.expense,
    this.isOverBudget = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.currencySymbol,
    );

    final Color typeColor = switch (type) {
      TransactionType.income => AppColors.primaryAccent,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };

    Widget content = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            GenericIconContainer(icon: icon, color: typeColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  totalNumberOfTransaction != 0
                      ? Text(
                          '${totalNumberOfTransaction.toStringAsFixed(0)} transaction',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            Text(
              '$currencySymbol ${totalSpent.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isOverBudget
                    ? AppColors.danger
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );

    if (onDelete != null) {
      return Slidable(
        key: ValueKey(name),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          closeThreshold: 0.7,
          dismissible: DismissiblePane(
            onDismissed: () {}, // Handled by confirmDismiss returning false
            closeOnCancel: true,
            confirmDismiss: () async {
              AppToast.show(
                context,
                type: AppToastType.deleteWithUndo,
                title: context.l10n.categoryDeleted,
                description: context.l10n.undoDeletionDescription,
                onCompleted: () => onDelete?.call(),
              );
              return false;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (context) async {
                AppToast.show(
                  context,
                  type: AppToastType.deleteWithUndo,
                  title: context.l10n.categoryDeleted,
                  description: context.l10n.undoDeletionDescription,
                  onCompleted: () => onDelete?.call(),
                );
              },
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              icon: PhosphorIconsBold.trash,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
