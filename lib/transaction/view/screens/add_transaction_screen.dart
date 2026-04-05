import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:budget_wise/currency_conversions/view/currency_conversion_preview.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_title_suggestions.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_toggle.dart';
import 'package:budget_wise/shared/widgets/category_dropdown.dart';
import 'package:budget_wise/shared/widgets/account_dropdown.dart';
import 'package:budget_wise/shared/widgets/date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';

class AddTransactionScreen extends StatefulWidget {
  static const String routeName = '/add-transaction';

  final TransactionModel? transactionToEdit;
  final String? initialAccountId;
  final double? initialAmount;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.initialAccountId,
    this.initialAmount,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final ValueNotifier<DateTime> _selectedDate;
  late final ValueNotifier<String?> _selectedCategoryId;
  late final ValueNotifier<String?> _selectedAccountId;
  late final ValueNotifier<String?> _selectedCurrency;
  late final ValueNotifier<TransactionType> _selectedType;

  final ValueNotifier<List<String>> _titleSuggestionsNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> _showSuggestionsNotifier = ValueNotifier(false);
  final FocusNode _titleFocusNode = FocusNode();
  final ValueNotifier<bool> _isBudgetWarningShown = ValueNotifier(false);
  double _convertedAmount = 0.0;
  bool get _isEditMode => widget.transactionToEdit != null;
  late final String defaultCurrencySymbol;

  @override
  void initState() {
    super.initState();
    defaultCurrencySymbol = context.read<SettingsBloc>().state.currencySymbol;
    if (_isEditMode) {
      final trans = widget.transactionToEdit!;
      _titleController.text = trans.transactionTitle;
      _amountController.text = trans.transactionAmount.toStringAsFixed(2);
      _notesController.text = trans.transactionNotes ?? '';
      _selectedCurrency = ValueNotifier(trans.transactionCurrency);
      _selectedDate = ValueNotifier(trans.transactionDate);
      _selectedCategoryId = ValueNotifier(trans.categoryId);
      _selectedAccountId = ValueNotifier(trans.accountId);
      _selectedType = ValueNotifier(trans.type);
    } else {
      _selectedDate = ValueNotifier(DateTime.now());
      _selectedType = ValueNotifier(TransactionType.expense);
      _selectedCategoryId = ValueNotifier(null);
      _selectedAccountId = ValueNotifier(widget.initialAccountId);
      _selectedCurrency = ValueNotifier(
        context.read<SettingsBloc>().state.model.defaultCurrency,
      );
      if (widget.initialAmount != null) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(2);
      }
    }
    _titleController.addListener(_onTitleChanged);
    _titleFocusNode.addListener(_onTitleFocusChanged);

    // Reset budget warning on changes
    _titleController.addListener(_resetBudgetWarning);
    _amountController.addListener(_resetBudgetWarning);
    _selectedDate.addListener(_resetBudgetWarning);
    _selectedCategoryId.addListener(_resetBudgetWarning);
    _selectedType.addListener(_resetBudgetWarning);
    _selectedAccountId.addListener(_onAccountChanged);
  }

  void _resetBudgetWarning() {
    if (_isBudgetWarningShown.value) {
      _isBudgetWarningShown.value = false;
    }
  }

  void _onAccountChanged() {
    if (_selectedAccountId.value != null) {
      final account = context.read<AccountBloc>().state.accountsList.firstWhere(
        (a) => a.id == _selectedAccountId.value,
      );
      _selectedCurrency.value = account.currency;
    }
  }

  void _onTitleChanged() {
    final searchText = _titleController.text.trim();
    if (searchText.isEmpty) {
      _titleSuggestionsNotifier.value = [];
      _showSuggestionsNotifier.value = false;
      return;
    }

    final allTitles = context
        .read<TransactionBloc>()
        .state
        .transactionsList
        .where((t) => t.type == _selectedType.value)
        .map((t) => t.transactionTitle)
        .toSet()
        .toList();

    final filteredSuggestions = allTitles
        .where(
          (title) => title.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();

    _titleSuggestionsNotifier.value = filteredSuggestions;

    _showSuggestionsNotifier.value =
        filteredSuggestions.isNotEmpty && _titleFocusNode.hasFocus;
  }

  void _onTitleFocusChanged() {
    if (!_titleFocusNode.hasFocus) {
      _showSuggestionsNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _selectedDate.dispose();
    _selectedCategoryId.dispose();
    _selectedAccountId.dispose();
    _selectedCurrency.dispose();
    _selectedType.dispose();
    _titleFocusNode.dispose();
    _titleSuggestionsNotifier.dispose();
    _showSuggestionsNotifier.dispose();
    super.dispose();
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);
    final l10n = AppLocalizations.of(context)!;

    if (title.isEmpty) {
      AppToast.show(context, type: AppToastType.error, title: l10n.enterTitle);
      return;
    }

    if (amount == null || amount <= 0) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: l10n.enterValidAmount,
      );
      return;
    }

    if (_selectedCategoryId.value == null) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: l10n.selectCategory,
      );
      return;
    }

    if (_selectedAccountId.value == null) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: l10n.selectAccount,
      );
      return;
    }

    // Check Category Budget Limit
    final selectedCategory = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where((c) => c.id == _selectedCategoryId.value)
        .firstOrNull;

    if (selectedCategory != null &&
        selectedCategory.hasBudgetAmount &&
        _selectedType.value == TransactionType.expense) {
      final currentSpending = context
          .read<TransactionBloc>()
          .state
          .getCategorySpending(
            categoryId: selectedCategory.id,
            month: _selectedDate.value.month,
            year: _selectedDate.value.year,
            excludeTransactionId: widget.transactionToEdit?.id,
          );

      if (currentSpending + amount > (selectedCategory.budgetAmount ?? 0)) {
        if (!_isBudgetWarningShown.value) {
          _isBudgetWarningShown.value = true;
          AppToast.show(
            context,
            type: AppToastType.warning,
            title: l10n.budgetExceeded,
            description: l10n.budgetExceededDescription(
              selectedCategory.categoryTitle,
            ),
          );
          return;
        }
      }
    }

    final selectedAccount = context
        .read<AccountBloc>()
        .state
        .accountsList
        .firstWhere((a) => a.id == _selectedAccountId.value);

    final finalAmountForAccount =
        (_selectedCurrency.value == selectedAccount.currency)
        ? amount
        : _convertedAmount;

    if (_isEditMode) {
      final updatedTransaction = widget.transactionToEdit!.copyWith(
        type: _selectedType.value,
        transactionTitle: title,
        transactionAmount: amount,
        transactionCurrency: _selectedCurrency.value ?? defaultCurrencySymbol,
        categoryId: _selectedCategoryId.value,
        accountId: _selectedAccountId.value,
        transactionDate: _selectedDate.value,
        transactionNotes: _notesController.text.trim(),
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      context.read<TransactionBloc>().add(
        TransactionEventUpdateTransaction(
          updatedTransaction,
          convertedAmount: finalAmountForAccount,
        ),
      );
    } else {
      final newTransaction = TransactionModel(
        type: _selectedType.value,
        transactionTitle: title,
        transactionAmount: amount,
        transactionCurrency: _selectedCurrency.value ?? defaultCurrencySymbol,
        categoryId: _selectedCategoryId.value!,
        accountId: _selectedAccountId.value!,
        transactionDate: _selectedDate.value,
        transactionNotes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<TransactionBloc>().add(
        TransactionEventCreateTransaction(
          newTransaction,
          convertedAmount: finalAmountForAccount,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          _isEditMode ? l10n.editTransaction : l10n.addTransactionTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: ValueListenableBuilder<TransactionType>(
            valueListenable: _selectedType,
            builder: (context, type, _) {
              final accentColor = type == TransactionType.income
                  ? AppColors.primaryAccent
                  : AppColors.expense;

              final typeLabel = type == TransactionType.income
                  ? l10n.addIncomeTitle
                  : l10n.addExpenseTitle;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransactionTypeToggle(
                      selectedType: _selectedType,
                      incomeLabel: l10n.income,
                      expenseLabel: l10n.expenses,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Column(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _showSuggestionsNotifier,
                          builder: (context, showSuggestions, child) {
                            return CustomTextField(
                              hintText: l10n.title,
                              controller: _titleController,
                              activeColor: accentColor,
                              focusNode: _titleFocusNode,
                              shouldUnfocusOnTapOutside: !showSuggestions,
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        ValueListenableBuilder<bool>(
                          valueListenable: _showSuggestionsNotifier,
                          builder: (context, showSuggestion, child) {
                            if (showSuggestion &&
                                _titleSuggestionsNotifier.value.isNotEmpty) {
                              return TransactionTitleSuggestions(
                                suggestions: _titleSuggestionsNotifier.value,
                                onTitleSelect: (titleSelected) {
                                  _titleController.text = titleSelected;
                                  _titleSuggestionsNotifier.value = [];
                                  _showSuggestionsNotifier.value = false;
                                  _titleFocusNode.unfocus();
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      hintText: l10n.amount,
                      controller: _amountController,
                      activeColor: accentColor,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ThousandsSeparatorInputFormatter(),
                      ],
                      prefixIcon: CurrencyPrefix(
                        selectedCurrencyNotifier: _selectedCurrency,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CategoryDropdown(
                      selectedTypeNotifier: _selectedType,
                      selectedCategoryId: _selectedCategoryId,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AccountDropdown(
                      selectedAccountId: _selectedAccountId,
                      selectedCurrency: _selectedCurrency,
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedAccountId,
                      builder: (context, accountId, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: _selectedCurrency,
                          builder: (context, currency, _) {
                            if (accountId == null || currency == null) {
                              return const SizedBox.shrink();
                            }

                            final account = context
                                .read<AccountBloc>()
                                .state
                                .accountsList
                                .firstWhere((a) => a.id == accountId);

                            if (account.currency == currency) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.lg,
                              ),
                              child: ListenableBuilder(
                                listenable: _amountController,
                                builder: (context, _) {
                                  final amount =
                                      double.tryParse(
                                        _amountController.text.replaceAll(
                                          ',',
                                          '',
                                        ),
                                      ) ??
                                      0.0;
                                  return CurrencyConversionPreview(
                                    amount: amount,
                                    fromCurrency: currency,
                                    toCurrency: account.currency,
                                    onConvertedAmountChanged: (val) {
                                      _convertedAmount = val;
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DatePickerField(
                      selectedDate: _selectedDate,
                      activeColor: accentColor,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      hintText: l10n.notesOP,
                      controller: _notesController,
                      maxLines: 4,
                      activeColor: accentColor,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isBudgetWarningShown,
                      builder: (context, isWarningShown, child) {
                        return CustomButton(
                          text: isWarningShown
                              ? l10n.saveAnyway
                              : (_isEditMode ? l10n.saveChanges : typeLabel),
                          onPressed: _onSave,
                          color: accentColor,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
