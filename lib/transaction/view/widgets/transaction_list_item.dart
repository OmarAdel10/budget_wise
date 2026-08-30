import 'package:auto_size_text/auto_size_text.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_bottom_sheet.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:shimmer/shimmer.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel model;
  final VoidCallback? onDelete;
  final bool hasBG;
  final bool? isRoot;

  const TransactionListItem({
    super.key,
    required this.model,
    this.onDelete,
    this.hasBG = true,
    this.isRoot,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLoggedIn = context.select<SettingsBloc, bool>(
      (settingsBloc) => settingsBloc.state.model.hasLoggedIn,
    );

    final accountTitle = context.select<AccountBloc, String>((accBloc) {
      final account = accBloc.state.accountsList
          .where((a) => a.id == model.accountId)
          .firstOrNull;
      return account?.title ?? context.l10n.noAccount;
    });

    final category = context.select<CategoryBloc, CategoryModel>(
      (catBloc) => (catBloc.state.categoriesList.firstWhere(
        (cat) => cat.id == model.categoryId,
        orElse: () => catBloc.state.categoriesList.first,
      )),
    );

    final accentColor = model.categoryId == SystemCategoryIds.accountTransfer
        ? AppColors.transfer
        : model.type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;

    String formatFriendlyDate() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateToCheck = model.transactionDate;

      if (dateToCheck.day == today.day) {
        return '${context.l10n.today}, ${DateFormat('hh:MM').format(dateToCheck)}';
      } else if (dateToCheck.day == yesterday.day) {
        return '${context.l10n.yesterday}, ${DateFormat('hh:MM').format(dateToCheck)}';
      } else {
        return DateFormat('dd MMM, hh:MM').format(dateToCheck);
      }
    }

    Widget content = GestureDetector(
      onTap: () => isRoot != null && !isRoot!
          ? Navigator.of(context).push(
              BottomSheetService.pageRoute(
                child: (context) => AddTransactionBottomSheet(
                  transactionToEdit: model,
                  isRoot: isRoot ?? true,
                ),
              ),
            )
          : showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  AddTransactionBottomSheet(transactionToEdit: model),
            ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: hasBG ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [AppBoxShadow()],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GenericIconContainer(
              icon: category.categoryIcon,
              color: accentColor,
              iconSize: 18,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notes
                if (model.transactionNotes != null &&
                    model.transactionNotes!.isNotEmpty) ...[
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    child: Text(
                      model.transactionNotes!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],

                // Description
                if (model.description != null) ...[
                  Text(
                    model.description!,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.start,
                  ),
                ],

                // Category
                Text(
                  category.categoryTitle.toTitleCase(),
                  style: model.description != null
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyLarge,
                  textAlign: TextAlign.start,
                ),

                // Account
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      accountTitle,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),

                // Sync text
                hasLoggedIn
                    ? AnimatedCrossFade(
                        firstChild: Shimmer.fromColors(
                          baseColor: AppColors.textSecondary,
                          highlightColor: Colors.grey.shade100,
                          enabled: true,
                          child: Text(
                            context.l10n.syncing,
                            style: AppTextStyles.bodySmall.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        secondChild: Text(
                          context.l10n.synced,
                          style: AppTextStyles.bodySmall.copyWith(
                            letterSpacing: 2,
                          ),
                        ),
                        crossFadeState: !model.isSynced
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      )
                    : const SizedBox.shrink(),
              ],
            ),

            // Amount + Date
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  model.type == TransactionType.income
                      ? "+ ${NumberFormat.currency(name: model.transactionCurrency).currencySymbol} ${model.transactionAmount.toStringAsFixed(0)}"
                      : "- ${NumberFormat.currency(name: model.transactionCurrency).currencySymbol} ${model.transactionAmount.toStringAsFixed(0)}",
                  maxLines: 1,
                  minFontSize: AppTextStyles.bodyMedium.fontSize!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatFriendlyDate(),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
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
            closeThreshold: 0.7,
            dismissible: DismissiblePane(
              onDismissed: () {}, // Handled by confirmDismiss returning false
              closeOnCancel: true,
              confirmDismiss: () async {
                // Use the current BuildContext for the toast (only one path will be triggered)
                AppToast.show(
                  context,
                  type: AppToastType.deleteWithUndo,
                  title: context.l10n.transactionDeleted,
                  description: context.l10n.undoDeletionDescription,
                  onCompleted: () => onDelete?.call(),
                );
                return false; // Slides back, pending toast autocomplete
              },
            ),
            children: [
              SlidableAction(
                onPressed: (context) {
                  // final stableContext = Navigator.of(context).context;
                  AppToast.show(
                    context,
                    type: AppToastType.deleteWithUndo,
                    title: context.l10n.transactionDeleted,
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
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: content,
    );
  }
}
