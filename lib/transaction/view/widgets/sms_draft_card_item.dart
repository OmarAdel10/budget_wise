import 'dart:developer';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_bloc.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_field.dart';
import 'package:budget_wise/transaction/view/widgets/category_field.dart';
import 'package:budget_wise/transaction/view/widgets/sms_draft_action_buttons.dart';
import 'package:budget_wise/transaction/view/widgets/accounts_transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'edit_draft_bottom_sheet.dart';

typedef TransactionConfirmCallback =
    Function(AccountModel selectedAccount, CategoryModel selectedCategory);
typedef TransferConfirmCallback =
    void Function(AccountModel fromAccount, AccountModel toAccount);

class SmsDraftCardItem extends StatefulWidget {
  final SmsDraftModel draft;
  final VoidCallback onDecline;
  final TransactionConfirmCallback? onTransactionConfirm;
  final TransferConfirmCallback? onTransferConfirm;

  bool get _isTransfer => onTransferConfirm != null;

  const SmsDraftCardItem.transaction({
    super.key,
    required this.draft,
    required TransactionConfirmCallback onConfirm,
    required this.onDecline,
  }) : onTransactionConfirm = onConfirm,
       onTransferConfirm = null;

  const SmsDraftCardItem.transfer({
    super.key,
    required this.draft,
    required TransferConfirmCallback onConfirm,
    required this.onDecline,
  }) : onTransferConfirm = onConfirm,
       onTransactionConfirm = null;

  @override
  State<SmsDraftCardItem> createState() => _SmsDraftCardItemState();
}

class _SmsDraftCardItemState extends State<SmsDraftCardItem> {
  late final ValueNotifier<String?> _selectedAccountIdNotifier;
  late final ValueNotifier<String?> _selectedCategoryIdNotifier;
  late final ValueNotifier<TransactionType> _typeNotifier;
  late final ValueNotifier<String> _categoryTitleNotifier;
  late final ValueNotifier<IconData> _categoryIconNotifier;
  late final ValueNotifier<bool> _categoryIsSelectedNotifier;
  late final ValueNotifier<String> _accountTitleNotifier;
  late final ValueNotifier<IconData> _accountIconNotifier;
  late final ValueNotifier<bool> _accountIsSelectedNotifier;

  final ValueNotifier<bool> _isBudgetWarningShown = ValueNotifier(false);

  late final ValueNotifier<String?> _fromAccountId;
  late final ValueNotifier<String?> _toAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountIdNotifier = ValueNotifier(null);
    _selectedCategoryIdNotifier = ValueNotifier(null);
    _typeNotifier = ValueNotifier(widget.draft.transactionType);
    _categoryTitleNotifier = ValueNotifier('');
    _categoryIconNotifier = ValueNotifier(PhosphorIconsRegular.tag);
    _accountTitleNotifier = ValueNotifier('');
    _accountIconNotifier = ValueNotifier(PhosphorIconsRegular.bank);
    _fromAccountId = ValueNotifier(null);
    _toAccountId = ValueNotifier(null);

    if (widget._isTransfer) {
      _fromAccountId.value = _initialFromAccountId();
      _toAccountId.value = _initialToAccountId();
    } else {
      _preSelectAccountFromLastFoutDigits();
      _initializeCategory();
      _selectedAccountIdNotifier.addListener(_resetBudgetWarning);
      _selectedCategoryIdNotifier.addListener(_resetBudgetWarning);
    }
    _accountIsSelectedNotifier = ValueNotifier(
      _selectedAccountIdNotifier.value != null,
    );
    _categoryIsSelectedNotifier = ValueNotifier(
      _selectedCategoryIdNotifier.value != null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget._isTransfer) {
      if (!_categoryIsSelectedNotifier.value) {
        _categoryTitleNotifier.value = context.l10n.selectCategory;
      }
      if (!_accountIsSelectedNotifier.value) {
        _accountTitleNotifier.value = context.l10n.selectAccount;
      }
    }
  }

  @override
  void dispose() {
    _selectedAccountIdNotifier.dispose();
    _selectedCategoryIdNotifier.dispose();
    _typeNotifier.dispose();
    _categoryTitleNotifier.dispose();
    _categoryIconNotifier.dispose();
    _categoryIsSelectedNotifier.dispose();
    _accountTitleNotifier.dispose();
    _accountIconNotifier.dispose();
    _accountIsSelectedNotifier.dispose();
    _fromAccountId.dispose();
    _toAccountId.dispose();
    super.dispose();
  }

  void _resetBudgetWarning() {
    if (_isBudgetWarningShown.value) {
      _isBudgetWarningShown.value = false;
    }
  }

  // --- Transaction helpers ---

  void _preSelectAccountFromLastFoutDigits() {
    if (widget.draft.extractedCardLastFour != null &&
        widget.draft.extractedCardLastFour!.isNotEmpty) {
      final account = context
          .read<AccountBloc>()
          .state
          .accountsList
          .where(
            (acc) => acc.smsIdentifier == widget.draft.extractedCardLastFour,
          )
          .firstOrNull;
      if (account != null) {
        _selectedAccountIdNotifier.value = account.id;
        _accountTitleNotifier.value = account.title;
        _accountIconNotifier.value = account.accountIcon;
        context.read<TransactionBloc>().add(
          TransactionEventUpdateSmsDraft(
            updatedDraft: widget.draft.copyWith(matchedAccountId: account.id),
          ),
        );
      } else {
        final defaultAccount = context
            .read<AccountBloc>()
            .state
            .accountsList
            .where((acc) => acc.isDefault)
            .firstOrNull;
        if (defaultAccount != null) {
          _selectedAccountIdNotifier.value = defaultAccount.id;
          _accountTitleNotifier.value = defaultAccount.title;
          _accountIconNotifier.value = defaultAccount.accountIcon;
        } else {
          _selectedAccountIdNotifier.value = null;
        }
      }
    }
    log(
      'acc id: ${_selectedAccountIdNotifier.value}',
      name: 'sms_draft_accrd_item',
    );
    log(
      'acc title: ${_accountTitleNotifier.value}',
      name: 'sms_draft_accrd_item',
    );
    log('acc icon: ${_accountIconNotifier.value}', name: 'sms_draft_card_item');
  }

  void _initializeCategory() {
    final categories = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where(
          (cat) => cat.type == widget.draft.transactionType && !cat.isSystem,
        )
        .toList();

    CategoryModel? selected;
    final merchant = widget.draft.extractedMerchant;
    final isMerchantRulesEnabled = context
        .read<SettingsBloc>()
        .state
        .model
        .merchantRulesEnabled;
    if (merchant != null && merchant.isNotEmpty && isMerchantRulesEnabled) {
      final learningState = context.read<MerchantCategoryLearningBloc>().state;
      selected = _categoryFromLearning(learningState, categories, merchant);
    }

    selected ??= _categoryFromSuggestion(categories);
    _selectedCategoryIdNotifier.value = selected?.id;
    if (selected != null &&
        (_selectedCategoryIdNotifier.value != null &&
            _selectedCategoryIdNotifier.value!.isNotEmpty)) {
      _categoryTitleNotifier.value = selected.categoryTitle.toTitleCase();
      _categoryIconNotifier.value = selected.categoryIcon;
    }
    if (_selectedCategoryIdNotifier.value == null ||
        _selectedCategoryIdNotifier.value!.isEmpty) {
      final category = categories
          .where(
            (cat) =>
                cat.isDefault && cat.categoryTitle.toLowerCase() == 'other',
          )
          .firstOrNull;
      if (category != null) {
        _selectedCategoryIdNotifier.value = category.id;
        _categoryTitleNotifier.value = category.categoryTitle.toTitleCase();
        _categoryIconNotifier.value = category.categoryIcon;
      }
    }
    log(
      'cat id: ${_selectedCategoryIdNotifier.value}',
      name: 'sms_draft_card_item',
    );
    log(
      'cat title: ${_categoryTitleNotifier.value}',
      name: 'sms_draft_card_item',
    );
    log(
      'cat icon: ${_categoryIconNotifier.value}',
      name: 'sms_draft_card_item',
    );
  }

  CategoryModel? _categoryFromLearning(
    MerchantCategoryLearningState learningState,
    List<CategoryModel> categories,
    String merchant,
  ) {
    final mappings =
        learningState.mappings
            .where(
              (mapping) =>
                  mapping.transactionType == widget.draft.transactionType,
            )
            .where((mapping) => mapping.matchesMerchant(merchant))
            .toList()
          ..sort((a, b) => b.useCount.compareTo(a.useCount));
    if (mappings.isEmpty) return null;

    final best = mappings.first;
    return categories.where((cat) => cat.id == best.categoryId).firstOrNull ??
        categories
            .where((cat) => cat.categoryTitle == best.categoryTitle)
            .firstOrNull;
  }

  CategoryModel? _categoryFromSuggestion(List<CategoryModel> categories) {
    if (widget.draft.suggestedCategoryTitle != null) {
      return categories
          .where(
            (cat) =>
                cat.categoryTitle.toLowerCase() ==
                widget.draft.suggestedCategoryTitle!.toLowerCase(),
          )
          .firstOrNull;
    }
    return null;
  }

  void _onConfirmTap(
    AccountModel selectedAccount,
    CategoryModel selectedCategory,
  ) {
    if (selectedCategory.hasBudgetAmount &&
        widget.draft.transactionType == TransactionType.expense) {
      final amount = widget.draft.extractedAmount ?? 0.0;
      final date = widget.draft.extractedDate ?? DateTime.now();

      final currentSpending = context
          .read<TransactionBloc>()
          .state
          .getCategorySpending(
            categoryId: selectedCategory.id,
            month: date.month,
            year: date.year,
          );

      if (currentSpending + amount > (selectedCategory.budgetAmount ?? 0)) {
        if (!_isBudgetWarningShown.value) {
          _isBudgetWarningShown.value = true;
          AppToast.show(
            context,
            type: AppToastType.warning,
            title: context.l10n.budgetExceeded,
            description: context.l10n.budgetExceededDescription(
              selectedCategory.categoryTitle,
            ),
          );
          return;
        }
      }
    }

    widget.onTransactionConfirm!(selectedAccount, selectedCategory);
  }

  // --- Transfer helpers ---

  String? _initialFromAccountId() {
    if (widget.draft.transferFromAccountId != null) {
      return widget.draft.transferFromAccountId;
    }
    if (widget.draft.transferDirection == SmsTransferDirection.outgoing) {
      return widget.draft.matchedAccountId;
    }
    return null;
  }

  String? _initialToAccountId() {
    if (widget.draft.transferToAccountId != null) {
      return widget.draft.transferToAccountId;
    }
    if (widget.draft.transferDirection == SmsTransferDirection.incoming) {
      return widget.draft.matchedAccountId;
    }
    return null;
  }

  AccountModel? _accountById(String? id) {
    if (id == null || id.isEmpty) return null;
    return context
        .read<AccountBloc>()
        .state
        .accountsList
        .where((account) => account.id == id)
        .firstOrNull;
  }

  void _confirm() {
    final fromAccount = _accountById(_fromAccountId.value);
    final toAccount = _accountById(_toAccountId.value);
    if (fromAccount == null || toAccount == null) return;
    if (fromAccount.id == toAccount.id) return;
    widget.onTransferConfirm!(fromAccount, toAccount);
  }

  // --- Shared ---

  Future<void> _editDraft() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

  Widget _buildTypeBadge(BuildContext context, bool isTransfer) {
    Color color;
    String label;
    if (isTransfer) {
      color = AppColors.transfer;
      label = context.l10n.transfer;
    } else {
      final income = widget.draft.transactionType == TransactionType.income;
      color = income ? AppColors.income : AppColors.expense;
      label = income ? context.l10n.income : context.l10n.expenses;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer = widget._isTransfer;
    final dateFormat = DateFormat('dd/MM/yyyy | hh:mm');
    final amountColor = isTransfer
        ? AppColors.transfer
        : widget.draft.transactionType == TransactionType.income
        ? AppColors.income
        : AppColors.expense;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [AppBoxShadow()],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.draft.extractedMerchant ??
                            (widget._isTransfer
                                ? 'Transfer Transaction'
                                : widget.draft.transactionType ==
                                      TransactionType.income
                                ? 'Income Transaction'
                                : 'Expense Transaction'),
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(
                          widget.draft.extractedDate ?? DateTime.now(),
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat.simpleCurrency(name: widget.draft.extractedCurrency ?? 'EGP').currencyName}${widget.draft.extractedAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.heading3.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTypeBadge(context, isTransfer),
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
            if (isTransfer)
              AccountsTransferCard(
                fromAccountId: _fromAccountId,
                toAccountId: _toAccountId,
              )
            else ...[
              AccountField(
                selectedAccountIdNotifier: _selectedAccountIdNotifier,
                titleNotifier: _accountTitleNotifier,
                iconNotifier: _accountIconNotifier,
                isSelectedNotifier: _accountIsSelectedNotifier,
              ),
              const SizedBox(height: AppSpacing.md),
              CategoryField(
                iconBackgroundColor: amountColor,
                selectedTypeNotifier: _typeNotifier,
                selectedCategoryIdNotifier: _selectedCategoryIdNotifier,
                titleNotifier: _categoryTitleNotifier,
                iconNotifier: _categoryIconNotifier,
                isSelectedNotifier: _categoryIsSelectedNotifier,
              ),
            ],
            SizedBox(height: isTransfer ? AppSpacing.lg : AppSpacing.xl),
            if (isTransfer)
              ValueListenableBuilder<String?>(
                valueListenable: _fromAccountId,
                builder: (context, fromId, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _toAccountId,
                    builder: (context, toId, _) {
                      final canConfirm =
                          fromId != null && toId != null && fromId != toId;
                      return SmsDraftActionButtons(
                        onConfirm: canConfirm ? _confirm : null,
                        onDecline: widget.onDecline,
                        onEdit: _editDraft,
                      );
                    },
                  );
                },
              )
            else
              ValueListenableBuilder<String?>(
                valueListenable: _selectedAccountIdNotifier,
                builder: (context, selectedAccountId, child) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _selectedCategoryIdNotifier,
                    builder: (context, selectedCategoryId, child) {
                      final selectedAccount = context
                          .read<AccountBloc>()
                          .state
                          .accountsList
                          .where((acc) => acc.id == selectedAccountId)
                          .firstOrNull;
                      final selectedCategory = context
                          .read<CategoryBloc>()
                          .state
                          .categoriesList
                          .where((cat) => cat.id == selectedCategoryId)
                          .firstOrNull;

                      return ValueListenableBuilder<bool>(
                        valueListenable: _isBudgetWarningShown,
                        builder: (context, isWarningShown, child) {
                          return SmsDraftActionButtons(
                            onConfirm:
                                (selectedAccount != null &&
                                    selectedCategory != null)
                                ? () => _onConfirmTap(
                                    selectedAccount,
                                    selectedCategory,
                                  )
                                : null,
                            onDecline: widget.onDecline,
                            onEdit: _editDraft,
                            isWarningShown: isWarningShown,
                          );
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
