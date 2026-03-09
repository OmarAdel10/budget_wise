import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'edit_draft_bottom_sheet.dart';

class DraftTransactionCardItem extends StatefulWidget {
  final SmsDraftModel draft;
  final Function(AccountModel selectedAccount, CategoryModel selectedCategory)
  onConfirm;
  final VoidCallback onDecline;

  const DraftTransactionCardItem({
    super.key,
    required this.draft,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  State<DraftTransactionCardItem> createState() =>
      _DraftTransactionCardItemState();
}

class _DraftTransactionCardItemState extends State<DraftTransactionCardItem> {
  final ValueNotifier<AccountModel?> _selectedAccountNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<CategoryModel?> _selectedCategoryNotifier = ValueNotifier(
    null,
  );

  @override
  void initState() {
    super.initState();
    _initializeAccount();
  }

  void _initializeAccount() {
    if (widget.draft.matchedAccountId != null &&
        widget.draft.matchedAccountId!.isNotEmpty) {
      _selectedAccountNotifier.value = context
          .read<AccountBloc>()
          .state
          .accountsList
          .where((acc) => acc.id == widget.draft.matchedAccountId)
          .firstOrNull;
    } else {
      _selectedAccountNotifier.value = null;
    }
  }

  @override
  void didUpdateWidget(DraftTransactionCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draft.matchedAccountId != oldWidget.draft.matchedAccountId) {
      _initializeAccount();
    }
    if (_selectedAccountNotifier.value != null) {
      if (_selectedAccountNotifier.value!.currency !=
          widget.draft.extractedCurrency) {
        _selectedAccountNotifier.value = null;
      }
    }
  }

  @override
  void dispose() {
    _selectedAccountNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  Future<void> _editDraft() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditDraftBottomSheet(
        title: widget.draft.extractedMerchant ?? widget.draft.sender,
        amount: widget.draft.extractedAmount ?? 0.0,
        date: widget.draft.extractedDate ?? DateTime.now(),
        type: widget.draft.transactionType,
        currency: widget.draft.extractedCurrency ?? 'EGP',
      ),
    );

    if (result != null && mounted) {
      final updatedDraft = widget.draft.copyWith(
        extractedMerchant: result['title'] as String,
        extractedAmount: result['amount'] as double,
        extractedDate: result['date'] as DateTime,
        transactionType: result['type'] as TransactionType,
        extractedCurrency: result['currency'] as String,
      );

      context.read<TransactionBloc>().add(
        TransactionEventUpdateSmsDraft(updatedDraft: updatedDraft),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy | hh:mm');
    final bool income = widget.draft.transactionType == TransactionType.income;
    final bool identificationFailed =
        widget.draft.matchedAccountId == null ||
        widget.draft.matchedAccountId!.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //* Row 1: Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Merchant & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.draft.extractedMerchant ?? widget.draft.sender,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<AccountModel?>(
                        valueListenable: _selectedAccountNotifier,
                        builder: (context, selectedAccount, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!identificationFailed &&
                                  widget.draft.extractedCardLastFour != null &&
                                  selectedAccount != null)
                                Text(
                                  '${selectedAccount.title} • ${widget.draft.extractedCardLastFour}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              Text(
                                dateFormat.format(
                                  widget.draft.extractedDate ?? DateTime.now(),
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Right Column: Amount & Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat.simpleCurrency(name: widget.draft.extractedCurrency ?? 'EGP').currencyName}${widget.draft.extractedAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.heading3.copyWith(
                        color: income
                            ? AppColors.primaryAccent
                            : AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (income ? AppColors.income : AppColors.expense)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: (income ? AppColors.income : AppColors.expense)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        income ? l10n.income : l10n.expenses,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: income ? AppColors.income : AppColors.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            const Divider(
              color: AppColors.borderColor,
              indent: 15,
              endIndent: 15,
            ),
            const SizedBox(height: AppSpacing.sm),

            //* Row 2: Form Fields
            if (identificationFailed) ...[
              _buildDropdownLabel(l10n.payment),
              const SizedBox(height: 8),
              _buildPaymentDropdown(),
              const SizedBox(height: AppSpacing.md),
            ],
            _buildDropdownLabel(l10n.category),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),

            const SizedBox(height: AppSpacing.xl),

            //* Column 1: Actions
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          backgroundColor: AppColors.danger.withValues(
                            alpha: .1,
                          ),
                          side: BorderSide(
                            color: AppColors.danger.withValues(alpha: .4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                        icon: Icon(
                          PhosphorIcons.trash(PhosphorIconsStyle.bold),
                          size: 18,
                        ),
                        label: Text(
                          l10n.decline,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ValueListenableBuilder<AccountModel?>(
                      valueListenable: _selectedAccountNotifier,
                      builder: (context, selectedAccount, child) {
                        return ValueListenableBuilder<CategoryModel?>(
                          valueListenable: _selectedCategoryNotifier,
                          builder: (context, selectedCategory, child) {
                            return Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    (selectedAccount != null &&
                                        selectedCategory != null)
                                    ? () => widget.onConfirm(
                                        selectedAccount,
                                        selectedCategory,
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent,
                                  foregroundColor: AppColors.textInverse,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  size: 18,
                                  color: AppColors.textInverse,
                                ),
                                label: Text(
                                  l10n.confirm,
                                  style: AppTextStyles.button,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editDraft,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          backgroundColor: AppColors.textSecondary.withValues(
                            alpha: .1,
                          ),
                          side: BorderSide(
                            color: AppColors.textSecondary.withValues(
                              alpha: .4,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                        icon: Icon(
                          PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          size: 18,
                        ),
                        label: Text(
                          l10n.editDraft,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildPaymentDropdown() {
    return ValueListenableBuilder(
      valueListenable: _selectedAccountNotifier,
      builder: (context, selectedAccount, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AccountModel>(
              value: selectedAccount,
              isExpanded: true,
              icon: Icon(
                PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                size: 16,
                color: AppColors.textSecondary,
              ),
              hint: Text(
                AppLocalizations.of(context)!.selectAccount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onChanged: (AccountModel? newValue) {
                if (_selectedAccountNotifier.value == newValue) return;
                _selectedAccountNotifier.value = newValue;
              },
              items: context
                  .read<AccountBloc>()
                  .state
                  .accountsList
                  .where(
                    (acc) =>
                        acc.accountType == AccountType.card &&
                        acc.currency == widget.draft.extractedCurrency,
                  )
                  .map((account) {
                    return DropdownMenuItem<AccountModel>(
                      value: account,
                      child: Row(
                        children: [
                          Icon(
                            account.accountIcon,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(account.title, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return ValueListenableBuilder<CategoryModel?>(
      valueListenable: _selectedCategoryNotifier,
      builder: (context, selectedCategory, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryModel>(
              value: selectedCategory,
              isExpanded: true,
              icon: Icon(
                PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                size: 16,
                color: AppColors.textSecondary,
              ),
              hint: Text(
                AppLocalizations.of(context)!.selectCategory,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onChanged: (CategoryModel? newValue) {
                if (_selectedCategoryNotifier.value == newValue) return;
                _selectedCategoryNotifier.value = newValue;
              },
              items: context
                  .read<CategoryBloc>()
                  .state
                  .categoriesList
                  .where((cat) => cat.type == widget.draft.transactionType)
                  .map((category) {
                    return DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            category.categoryIcon,
                            size: 20,
                            color: category.type == TransactionType.income
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            category.categoryTitle,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
