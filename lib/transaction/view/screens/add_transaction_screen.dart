import 'dart:developer';
import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_title_suggestions.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_toggle.dart';
import 'package:budget_wise/shared/widgets/category_dropdown.dart';
import 'package:budget_wise/transaction/view/widgets/account_dropdown.dart';
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

  const AddTransactionScreen({super.key, this.transactionToEdit});

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
      _selectedAccountId = ValueNotifier(null);
      _selectedCurrency = ValueNotifier(
        context.read<SettingsBloc>().state.model.defaultCurrency,
      );
    }
    _titleController.addListener(_onTitleChanged);
    _titleFocusNode.addListener(_onTitleFocusChanged);
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
    log('_titleFocusNode.hasFocus: ${_titleFocusNode.hasFocus}');
    log(
      '_titleController.text.isNotEmpty: ${_titleController.text.isNotEmpty}',
    );
    log(
      '_titleSuggestionsNotifier.value.isNotEmpty: ${_titleSuggestionsNotifier.value.isNotEmpty}',
    );

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
        TransactionEventUpdateTransaction(updatedTransaction),
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
        TransactionEventCreateTransaction(newTransaction),
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    CustomButton(
                      text: _isEditMode ? l10n.saveChanges : typeLabel,
                      onPressed: _onSave,
                      color: accentColor,
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
