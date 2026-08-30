import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/buckets/view/screens/add_saving_goal_screen.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/main.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/currency_conversions/view/currency_conversion_preview.dart';
import 'package:budget_wise/shared/utils/delete_dialog.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/widgets/convert_dialog.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_bottom_sheet.dart';
import 'package:budget_wise/transaction/data/models/transaction_extensions.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/amount_field.dart';
import 'package:budget_wise/transaction/view/widgets/category_field.dart';
import 'package:budget_wise/transaction/view/widgets/description_field.dart';
import 'package:budget_wise/transaction/view/widgets/notes_field.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/services/add_transaction_save_service.dart';
import 'package:budget_wise/shared/widgets/type_tab_bar.dart';
import 'package:budget_wise/shared/widgets/date_picker_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_field.dart';
import 'package:budget_wise/transaction/view/widgets/accounts_transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AddTransactionBottomSheet extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  final String? initialAccountId;
  final double? initialAmount;
  final bool isRoot;

  const AddTransactionBottomSheet({
    super.key,
    this.transactionToEdit,
    this.initialAccountId,
    this.initialAmount,
    this.isRoot = true,
  });

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final ValueNotifier<DateTime> _selectedDate;
  late final ValueNotifier<String?> _selectedCategoryId;
  late final ValueNotifier<String?> _fromAccountId;
  late final ValueNotifier<String?> _toAccountId;
  late final ValueNotifier<String?> _selectedCurrency;
  late final ValueNotifier<TransactionType> _selectedType;
  final FocusNode _descriptionFocusNode = FocusNode();
  final ValueNotifier<bool> _isBudgetWarningShown = ValueNotifier(false);
  double _convertedAmount = 0.0;
  bool get _isEditMode => widget.transactionToEdit != null;
  final ValueNotifier<bool> _canSave = ValueNotifier(true);
  late final String defaultCurrencySymbol;
  late final CategoryModel? _defaultCategory;

  late final AddTransactionSaveService _saveService;

  bool _isBalanceAdjustment = false;
  bool _isAccountTransfer = false;

  late final ValueNotifier<String> _categoryTitleNotifier;
  late final ValueNotifier<IconData> _categoryIconNotifier;
  late final ValueNotifier<bool> _categoryIsSelectedNotifier;
  late final ValueNotifier<String> _accountTitleNotifier;
  late final ValueNotifier<IconData> _accountIconNotifier;
  late final ValueNotifier<bool> _accountIsSelectedNotifier;

  final GlobalKey<NavigatorState> _navStateKey = GlobalKey();
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    defaultCurrencySymbol = context.read<SettingsBloc>().state.currencySymbol;

    _categoryTitleNotifier = ValueNotifier('');
    _categoryIconNotifier = ValueNotifier(PhosphorIconsRegular.tag);

    _accountTitleNotifier = ValueNotifier('');
    _accountIconNotifier = ValueNotifier(PhosphorIconsRegular.bank);

    if (_isEditMode) {
      final trans = widget.transactionToEdit!;
      _descriptionController.text = trans.description ?? '';
      _amountController.text = trans.transactionAmount.toStringAsFixed(2);
      _notesController.text = trans.transactionNotes ?? '';
      _selectedCurrency = ValueNotifier(trans.transactionCurrency);
      _selectedDate = ValueNotifier(trans.transactionDate);
      _selectedCategoryId = ValueNotifier(trans.categoryId);
      _fromAccountId = ValueNotifier(trans.accountId);
      _toAccountId = ValueNotifier(trans.toAccountId);
      _selectedType = ValueNotifier(trans.type);
      _isBalanceAdjustment = trans.isBalanceAdjustment;
      _isAccountTransfer = trans.isAccountTransfer;
      final cat = context
          .read<CategoryBloc>()
          .state
          .categoriesList
          .where((cat) => cat.id == _selectedCategoryId.value)
          .first;
      final acc = context
          .read<AccountBloc>()
          .state
          .accountsList
          .where((acc) => acc.id == _fromAccountId.value)
          .first;
      _categoryTitleNotifier.value = cat.categoryTitle.toTitleCase();
      _categoryIconNotifier.value = cat.categoryIcon;
      _accountTitleNotifier.value = acc.title;
      _accountIconNotifier.value = acc.accountIcon;
    } else {
      _selectedDate = ValueNotifier(DateTime.now());
      _selectedType = ValueNotifier(TransactionType.expense);
      _selectedCategoryId = ValueNotifier(null);
      if (widget.initialAccountId != null) {
        _fromAccountId = ValueNotifier(widget.initialAccountId);
      } else {
        final defaultAccount = context
            .read<AccountBloc>()
            .state
            .accountsList
            .where((acc) => acc.isDefault)
            .firstOrNull;
        if (defaultAccount != null) {
          _fromAccountId = ValueNotifier(defaultAccount.id);
          _accountTitleNotifier.value = defaultAccount.title;
          _accountIconNotifier.value = defaultAccount.accountIcon;
        } else {
          _fromAccountId = ValueNotifier(null);
        }
      }
      _toAccountId = ValueNotifier(null);
      _selectedCurrency = ValueNotifier(
        context.read<SettingsBloc>().state.model.defaultCurrency,
      );

      if (widget.initialAmount != null) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(2);
      }
    }

    _accountIsSelectedNotifier = ValueNotifier(_fromAccountId.value != null);
    _categoryIsSelectedNotifier = ValueNotifier(
      _selectedCategoryId.value != null,
    );

    _saveService = AddTransactionSaveService(
      transactionBloc: context.read<TransactionBloc>(),
      accountBloc: context.read<AccountBloc>(),
      categoryBloc: context.read<CategoryBloc>(),
      settingsBloc: context.read<SettingsBloc>(),
    );

    _amountController.addListener(_resetBudgetWarning);
    _selectedCategoryId.addListener(_resetBudgetWarning);
    _selectedType.addListener(_resetBudgetWarning);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategoryId.value == null) {
      _categoryTitleNotifier.value = context.l10n.selectCategory;
    }
    if (_fromAccountId.value == null) {
      _accountTitleNotifier.value = context.l10n.selectAccount;
    }
    _defaultCategory = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where(
          (cat) =>
              cat.isDefault &&
              cat.type == _selectedType.value &&
              cat.categoryTitle == 'other',
        )
        .firstOrNull;
  }

  void _resetBudgetWarning() {
    if (_isBudgetWarningShown.value) {
      _isBudgetWarningShown.value = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _selectedDate.dispose();
    _selectedCategoryId.dispose();
    _fromAccountId.dispose();
    _toAccountId.dispose();
    _selectedCurrency.dispose();
    _selectedType.dispose();
    _descriptionFocusNode.dispose();
    _categoryTitleNotifier.dispose();
    _categoryIconNotifier.dispose();
    _categoryIsSelectedNotifier.dispose();
    _accountTitleNotifier.dispose();
    _accountIconNotifier.dispose();
    _accountIsSelectedNotifier.dispose();
    super.dispose();
  }

  void _onDelete() {
    _saveService.deleteTransaction(widget.transactionToEdit!.id);

    AppToast.show(
      context,
      type: AppToastType.success,
      title: context.l10n.transactionDeletedSuccessfully,
    );
    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _isSavingOrSubscriptionCategory() {
    final categoryId = _selectedCategoryId.value;
    if (categoryId == null) return false;

    // Check by known IDs first
    if (categoryId == 'subscriptions') return true;

    // Also check by category title
    final category = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where((c) => c.id == categoryId)
        .firstOrNull;

    if (category == null) return false;

    final title = category.categoryTitle.toLowerCase();
    return title.contains('saving') ||
        title.contains('savings') ||
        title.contains('subscription') ||
        title.contains('subscriptions');
  }

  void _handleAtmWithdrawal(double amount, String description) {
    // Find the default cash account
    final defaultCashAccount = context
        .read<AccountBloc>()
        .state
        .accountsList
        .where((a) => a.accountType == AccountType.cash && a.isDefault)
        .firstOrNull;

    if (defaultCashAccount == null) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: 'No default cash account found',
        description: 'Please create a cash account and set it as default.',
      );
      return;
    }

    if (_fromAccountId.value == defaultCashAccount.id) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: 'Cannot withdraw from cash account',
        description: 'Select a different non-cash account to withdraw from.',
      );
      return;
    }

    // If editing, delete the old transaction first
    if (_isEditMode) {
      _saveService.deleteTransaction(widget.transactionToEdit!.id);
    }

    final fromAccount = context
        .read<AccountBloc>()
        .state
        .accountsList
        .firstWhere((a) => a.id == _fromAccountId.value);

    final fromDesc = 'ATM Withdrawal - ${fromAccount.title}';
    final toDesc = 'Cash Deposit - ATM Withdrawal';

    _saveService.saveTransfer(
      fromAccountId: _fromAccountId.value!,
      toAccountId: defaultCashAccount.id,
      amount: amount,
      fromCurrency: fromAccount.currency,
      destinationAmount: amount,
      destinationCurrency: defaultCashAccount.currency,
      date: _selectedDate.value,
      notes: _notesController.text.trim(),
      fromDescription: fromDesc,
      toDescription: toDesc,
      categoryId: 'atm_withdrawal',
    );

    AppToast.show(
      context,
      type: AppToastType.success,
      title: context.l10n.transactionSavedSuccessfully,
    );
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _promptConvert(double amount, String description) {
    final categoryId = _selectedCategoryId.value;
    if (categoryId == null) return;

    // Determine the convert type
    final category = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where((c) => c.id == categoryId)
        .firstOrNull;
    final title = category?.categoryTitle.toLowerCase() ?? '';
    final isSubscription =
        categoryId == 'subscriptions' ||
        title.contains('subscription') ||
        title.contains('subscriptions');
    final convertType = isSubscription
        ? ConvertType.subscription
        : ConvertType.saving;

    showDialog(
      context: context,
      builder: (dialogContext) => ConvertDialog(
        convertType: convertType,
        onConvert: () {
          // Save the transaction normally (this pops the bottom sheet)
          _executeSave(amount, description);
          // Navigate to creation screen using the global app context
          // after a short delay to let the bottom sheet close
          Future.delayed(const Duration(milliseconds: 300), () {
            final appContext = BudgetWise.navigatorKey.currentContext;
            if (appContext != null && appContext.mounted) {
              _navigateToCreationScreen(isSubscription, context: appContext);
            }
          });
        },
        onSaveTransaction: () {
          // Just save the transaction normally
          _executeSave(amount, description);
        },
      ),
    );
  }

  void _navigateToCreationScreen(
    bool isSubscription, {
    required BuildContext context,
  }) {
    if (isSubscription) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (ctx) => const AddSubscriptionBottomSheet(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (ctx) => const AddSavingGoalScreen(),
      );
    }
  }

  void _executeSave(double amount, String description) {
    if (!context.mounted) return;

    if (_selectedType.value == TransactionType.expense) {
      if (_saveService.isBudgetExceeded(
        categoryId: _selectedCategoryId.value,
        amount: amount,
        type: _selectedType.value,
        month: _selectedDate.value,
        excludeTransactionId: widget.transactionToEdit?.id,
      )) {
        if (!_isBudgetWarningShown.value) {
          _isBudgetWarningShown.value = true;
          AppToast.show(
            context,
            type: AppToastType.warning,
            title: context.l10n.budgetExceeded,
            description: context.l10n.budgetExceededDescription(
              context
                      .read<CategoryBloc>()
                      .state
                      .categoriesList
                      .where((c) => c.id == _selectedCategoryId.value)
                      .firstOrNull
                      ?.categoryTitle ??
                  '',
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
        .firstWhere((a) => a.id == _fromAccountId.value);

    final finalAmountForAccount =
        (_selectedCurrency.value == selectedAccount.currency)
        ? amount
        : _convertedAmount;

    if (_isEditMode &&
        (_selectedType.value == TransactionType.transfer ||
            _isAccountTransfer)) {
      _saveService.updateTransfer(
        existing: widget.transactionToEdit!,
        amount: finalAmountForAccount,
        notes: _notesController.text.trim(),
        date: _selectedDate.value,
      );
    } else if (_selectedType.value == TransactionType.transfer) {
      final fromAccount = context
          .read<AccountBloc>()
          .state
          .accountsList
          .firstWhere((a) => a.id == _fromAccountId.value);
      final toAccount = context
          .read<AccountBloc>()
          .state
          .accountsList
          .firstWhere((a) => a.id == _toAccountId.value);

      final fromDesc = context.l10n.transferFrom(fromAccount.title);
      final toDesc = context.l10n.transferTo(toAccount.title);

      _saveService.saveTransfer(
        fromAccountId: _fromAccountId.value!,
        toAccountId: _toAccountId.value!,
        amount: finalAmountForAccount,
        fromCurrency: fromAccount.currency,
        destinationAmount: finalAmountForAccount,
        destinationCurrency: toAccount.currency,
        date: _selectedDate.value,
        notes: _notesController.text.trim(),
        fromDescription: fromDesc,
        toDescription: toDesc,
        onBudgetExceeded: () {
          AppToast.show(
            context,
            title: context.l10n.budgetLimitExceeded,
            type: AppToastType.warning,
          );
        },
      );
    } else {
      _saveService.saveNormal(
        type: _selectedType.value,
        amount: amount,
        convertedAmount: finalAmountForAccount,
        currency: _selectedCurrency.value ?? defaultCurrencySymbol,
        categoryId: _selectedCategoryId.value,
        accountId: _fromAccountId.value!,
        toAccountId: _toAccountId.value,
        date: _selectedDate.value,
        notes: _notesController.text.trim(),
        description: description,
        defaultCurrencySymbol: defaultCurrencySymbol,
        existing: widget.transactionToEdit,
        onUpdateBudgetExceeded: () {
          AppToast.show(
            context,
            title: context.l10n.budgetLimitExceeded,
            type: AppToastType.warning,
          );
        },
        onCreateBudgetExceeded: () {
          final ctx = BudgetWise.navigatorKey.currentContext;
          if (ctx != null) {
            AppToast.show(
              ctx,
              title: ctx.l10n.budgetLimitExceeded,
              type: AppToastType.warning,
            );
          }
        },
      );
    }
    AppToast.show(
      context,
      type: AppToastType.success,
      title: context.l10n.transactionSavedSuccessfully,
    );
    Navigator.of(context, rootNavigator: widget.isRoot).pop();
  }

  void _onSave() {
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: context.l10n.enterValidAmount,
      );
      _canSave.value = false;
      return;
    }

    //! return later to delete it cause i'll stop editing the amount in the ui
    if (_isBalanceAdjustment && _isEditMode) {
      final oldAmount = widget.transactionToEdit!.transactionAmount;
      if (amount != oldAmount) {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: 'Cannot change amount',
        );
        _amountController.text = oldAmount.toStringAsFixed(2);
        return;
      }
    }

    if (_selectedType.value != TransactionType.transfer) {
      if (_selectedCategoryId.value == null) {
        AppToast.show(
          context,
          type: AppToastType.warning,
          title:
              'if there is no category selected, the "Other" category is auto selected',
          description: 'press save button again to save the transaction',
        );
        if (_defaultCategory != null) {
          _selectedCategoryId.value = _defaultCategory.id;
        } else {
          AppToast.show(
            context,
            type: AppToastType.warning,
            title:
                'there was a problem with the category auto selection, please select a category manually',
          );
          _canSave.value = false;
        }
        return;
      }
    }

    if (_fromAccountId.value == null) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: context.l10n.selectAccount,
      );
      _canSave.value = false;
      return;
    }

    if (_selectedType.value == TransactionType.transfer) {
      if (_toAccountId.value == null) {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: context.l10n.selectToAccount,
        );
        _canSave.value = false;
        return;
      }
      if (_fromAccountId.value == _toAccountId.value) {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: context.l10n.sameAccountError,
        );
        _canSave.value = false;
        return;
      }
    }

    _canSave.value = true;

    // --- ATM WITHDRAWAL HANDLING ---
    if (_selectedCategoryId.value == 'atm_withdrawal') {
      _handleAtmWithdrawal(amount, description);
      return;
    }

    // --- SAVING/SUBSCRIPTION PROMPT (EDIT MODE ONLY) ---
    if (_isEditMode && _isSavingOrSubscriptionCategory()) {
      _promptConvert(amount, description);
      return;
    }

    // --- NORMAL SAVE FLOW ---
    _executeSave(amount, description);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isRoot) {
      return DraggableScrollableSheet(
        shouldCloseOnMinExtent: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Navigator(
            key: _navStateKey,
            onGenerateRoute: (settings) => BottomSheetService.pageRoute(
              child: (context) => _TransactionFormBody(
                selectedType: _selectedType,
                selectedCategoryId: _selectedCategoryId,
                fromAccountId: _fromAccountId,
                toAccountId: _toAccountId,
                selectedCurrency: _selectedCurrency,
                selectedDate: _selectedDate,
                isBudgetWarningShown: _isBudgetWarningShown,
                canSaveNotifier: _canSave,
                amountController: _amountController,
                descriptionController: _descriptionController,
                notesController: _notesController,
                descriptionFocusNode: _descriptionFocusNode,
                onSave: _onSave,
                onDelete: _isEditMode ? _onDelete : null,
                isEditMode: _isEditMode,
                isBalanceAdjustment: _isBalanceAdjustment,
                isAccountTransfer: _isAccountTransfer,
                defaultCurrencySymbol: defaultCurrencySymbol,
                onConvertedAmountChanged: (val) => _convertedAmount = val,
                categoryTitleNotifier: _categoryTitleNotifier,
                categoryIconNotifier: _categoryIconNotifier,
                categoryIsSelectedNotifier: _categoryIsSelectedNotifier,
                accountTitleNotifier: _accountTitleNotifier,
                accountIconNotifier: _accountIconNotifier,
                accountIsSelectedNotifier: _accountIsSelectedNotifier,
                scrollController: scrollController,
                isRoot: widget.isRoot,
              ),
            ),
          ),
        ),
      );
    }

    return _TransactionFormBody(
      selectedType: _selectedType,
      selectedCategoryId: _selectedCategoryId,
      fromAccountId: _fromAccountId,
      toAccountId: _toAccountId,
      selectedCurrency: _selectedCurrency,
      selectedDate: _selectedDate,
      isBudgetWarningShown: _isBudgetWarningShown,
      canSaveNotifier: _canSave,
      amountController: _amountController,
      descriptionController: _descriptionController,
      notesController: _notesController,
      descriptionFocusNode: _descriptionFocusNode,
      onSave: _onSave,
      onDelete: _isEditMode ? _onDelete : null,
      isEditMode: _isEditMode,
      isBalanceAdjustment: _isBalanceAdjustment,
      isAccountTransfer: _isAccountTransfer,
      defaultCurrencySymbol: defaultCurrencySymbol,
      onConvertedAmountChanged: (val) => _convertedAmount = val,
      categoryTitleNotifier: _categoryTitleNotifier,
      categoryIconNotifier: _categoryIconNotifier,
      categoryIsSelectedNotifier: _categoryIsSelectedNotifier,
      accountTitleNotifier: _accountTitleNotifier,
      accountIconNotifier: _accountIconNotifier,
      accountIsSelectedNotifier: _accountIsSelectedNotifier,
      scrollController: _pageScrollController,
      isRoot: widget.isRoot,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TransactionFormBody extends StatelessWidget {
  final ValueNotifier<TransactionType> selectedType;
  final ValueNotifier<String?> selectedCategoryId;
  final ValueNotifier<String?> fromAccountId;
  final ValueNotifier<String?> toAccountId;
  final ValueNotifier<String?> selectedCurrency;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<bool> isBudgetWarningShown;
  final ValueNotifier<bool> canSaveNotifier;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final TextEditingController notesController;
  final FocusNode descriptionFocusNode;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final bool isEditMode;
  final bool isBalanceAdjustment;
  final bool isAccountTransfer;
  final String defaultCurrencySymbol;
  final ValueChanged<double> onConvertedAmountChanged;
  final ValueNotifier<String> categoryTitleNotifier;
  final ValueNotifier<IconData> categoryIconNotifier;
  final ValueNotifier<bool> categoryIsSelectedNotifier;
  final ValueNotifier<String> accountTitleNotifier;
  final ValueNotifier<IconData> accountIconNotifier;
  final ValueNotifier<bool> accountIsSelectedNotifier;
  final ScrollController scrollController;
  final bool? isRoot;

  const _TransactionFormBody({
    required this.selectedType,
    required this.selectedCategoryId,
    required this.fromAccountId,
    required this.toAccountId,
    required this.selectedCurrency,
    required this.selectedDate,
    required this.isBudgetWarningShown,
    required this.canSaveNotifier,
    required this.amountController,
    required this.descriptionController,
    required this.notesController,
    required this.descriptionFocusNode,
    required this.onSave,
    this.onDelete,
    required this.isEditMode,
    required this.isBalanceAdjustment,
    required this.isAccountTransfer,
    required this.defaultCurrencySymbol,
    required this.onConvertedAmountChanged,
    required this.categoryTitleNotifier,
    required this.categoryIconNotifier,
    required this.categoryIsSelectedNotifier,
    required this.accountTitleNotifier,
    required this.accountIconNotifier,
    required this.accountIsSelectedNotifier,
    required this.scrollController,
    this.isRoot,
  });

  bool get _isSystemTransaction => isBalanceAdjustment || isAccountTransfer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            BottomSheetService.header(
              title: isEditMode
                  ? context.l10n.editTransaction
                  : context.l10n.addTransactionTitle,
              isRoot: isRoot ?? true,
              actions: [
                GestureDetector(
                  onTap: onSave,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: canSaveNotifier,
                    builder: (context, canSave, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: canSave
                                  ? AppColors.primaryAccent.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.danger.withValues(alpha: 0.25),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Icon(
                          PhosphorIconsRegular.check,
                          color: AppColors.primaryAccent,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ValueListenableBuilder<TransactionType>(
              valueListenable: selectedType,
              builder: (context, type, _) {
                final accentColor = type == TransactionType.income
                    ? AppColors.primaryAccent
                    : type == TransactionType.expense
                    ? AppColors.expense
                    : AppColors.transfer;

                return Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      if (!_isSystemTransaction)
                        SliverToBoxAdapter(
                          child: TypeTabBar.forTransactionTypes(
                            selectionNotifier: selectedType,
                            padding: EdgeInsets.zero,
                            isScrollable: false,
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            AmountField(
                              key: const PageStorageKey('amount_key'),
                              amountController: amountController,
                              selectedCurrency: selectedCurrency,
                              readOnly: isBalanceAdjustment,
                            ),
                            if (type != TransactionType.transfer) ...[
                              if (!isAccountTransfer) ...[
                                const SizedBox(height: AppSpacing.lg),
                                DescriptionField(
                                  controller: descriptionController,
                                  focusNode: descriptionFocusNode,
                                  selectedType: type,
                                ),
                              ],
                              if (!isBalanceAdjustment &&
                                  !isAccountTransfer) ...[
                                const SizedBox(height: AppSpacing.lg),
                                CategoryField(
                                  iconBackgroundColor: accentColor,
                                  selectedTypeNotifier: selectedType,
                                  selectedCategoryIdNotifier:
                                      selectedCategoryId,
                                  titleNotifier: categoryTitleNotifier,
                                  iconNotifier: categoryIconNotifier,
                                  isSelectedNotifier:
                                      categoryIsSelectedNotifier,
                                ),
                              ],
                              if (!isAccountTransfer) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AccountField(
                                  selectedAccountIdNotifier: fromAccountId,
                                  titleNotifier: accountTitleNotifier,
                                  iconNotifier: accountIconNotifier,
                                  isSelectedNotifier: accountIsSelectedNotifier,
                                ),
                              ],
                            ] else ...[
                              const SizedBox(height: AppSpacing.lg),
                              AccountsTransferCard(
                                fromAccountId: fromAccountId,
                                toAccountId: toAccountId,
                              ),
                            ],
                          ]),
                        ),
                      ),
                      if (!isAccountTransfer)
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            fromAccountId,
                            selectedCurrency,
                          ]),
                          builder: (context, _) {
                            final accountId = fromAccountId.value;
                            final currency = selectedCurrency.value;

                            if (accountId == null || currency == null) {
                              return const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }

                            final account = context
                                .read<AccountBloc>()
                                .state
                                .accountsList
                                .where((a) => a.id == accountId)
                                .firstOrNull;

                            if (account == null ||
                                account.currency == currency) {
                              return const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }

                            return SliverPadding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.lg,
                              ),
                              sliver: ListenableBuilder(
                                listenable: amountController,
                                builder: (context, _) {
                                  final amount =
                                      double.tryParse(
                                        amountController.text.replaceAll(
                                          ',',
                                          '',
                                        ),
                                      ) ??
                                      0.0;
                                  return SliverToBoxAdapter(
                                    child: CurrencyConversionPreview(
                                      amount: amount,
                                      fromCurrency: currency,
                                      toCurrency: account.currency,
                                      onConvertedAmountChanged:
                                          onConvertedAmountChanged,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            DatePickerField(
                              label: context.l10n.dateLabel,
                              selectedDate: selectedDate,
                              activeColor: accentColor,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            NotesField(
                              controller: notesController,
                              selectedType: type,
                            ),
                            if (isEditMode && onDelete != null) ...[
                              const SizedBox(height: AppSpacing.xl),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => DeleteDialog(
                                        deletingType:
                                            context.l10n.transactionLabel,
                                        onDelete: onDelete,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    PhosphorIconsRegular.trash,
                                    color: AppColors.danger,
                                  ),
                                  label: const Text(
                                    'Delete Transaction',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.danger,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 16,
                                    backgroundColor: AppColors.danger
                                        .withValues(alpha: 0.05),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                          ]),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isBudgetWarningShown,
                        builder: (context, isWarningShown, child) {
                          if (isWarningShown) {
                            return SliverToBoxAdapter(
                              child: CustomButton(
                                text: context.l10n.saveAnyway,
                                onPressed: onSave,
                                color: accentColor,
                              ),
                            );
                          }
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
