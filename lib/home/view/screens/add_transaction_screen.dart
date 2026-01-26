import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view_model/category_state.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

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
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  late TransactionType _selectedType;

  bool get _isEditMode => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final trans = widget.transactionToEdit!;
      _titleController.text = trans.transactionTitle;
      _amountController.text = trans.transactionAmount.toStringAsFixed(2);
      _notesController.text = trans.transactionNotes ?? '';
      _selectedDate = trans.transactionDate;
      _selectedCategoryId = trans.categoryId;
      _selectedAccountId = trans.accountId;
      _selectedType = trans.type;
    } else {
      _selectedDate = DateTime.now();
      _selectedType = TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAccent,
              onPrimary: AppColors.textInverse,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    if (_isEditMode) {
      final updatedTransaction = widget.transactionToEdit!.copyWith(
        type: _selectedType,
        transactionTitle: title,
        transactionAmount: amount,
        categoryId: _selectedCategoryId,
        accountId: _selectedAccountId,
        transactionDate: _selectedDate,
        transactionNotes: _notesController.text.trim(),
        isSynced: false,
      );
      context.read<TransactionBloc>().add(
        TransactionEventUpdateTransaction(updatedTransaction),
      );
    } else {
      final newTransaction = TransactionModel(
        type: _selectedType,
        transactionTitle: title,
        transactionAmount: amount,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        transactionDate: _selectedDate,
        transactionNotes: _notesController.text.trim(),
      );
      context.read<TransactionBloc>().add(
        TransactionEventCreateTransaction(newTransaction),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final categories = categoryState.categoriesList
            .where((c) => c.type == _selectedType)
            .toList();

        // Reset selected category if it doesn't match the current type
        if (_selectedCategoryId != null &&
            !categories.any((c) => c.id == _selectedCategoryId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedCategoryId = null;
            });
          });
        }

        final typeLabel = _selectedType == TransactionType.income
            ? 'Income'
            : 'Expense';

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
              _isEditMode ? "Edit Transaction" : "Add Transaction",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income/Expense Toggle
                  _buildTransactionTypeToggle(),
                  const SizedBox(height: AppSpacing.lg),

                  // Title Input
                  CustomTextField(
                    hintText: "Title",
                    controller: _titleController,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount Input
                  CustomTextField(
                    hintText: "Amount",
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Category Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryId,
                        hint: Text(
                          "Category",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        isExpanded: true,
                        dropdownColor: AppColors.cardBackground,
                        icon: Icon(
                          PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                          color: AppColors.textSecondary,
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(
                              cat.categoryTitle,
                              style: AppTextStyles.bodyLarge,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryId = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Account Dropdown
                  BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, accountState) {
                      // Filter out accounts with empty ids and remove duplicates by id
                      final rawAccounts = accountState.accountsList;
                      final seenIds = <String>{};
                      final accounts = rawAccounts.where((a) {
                        if (a.id.isEmpty) return false;
                        if (seenIds.contains(a.id)) return false;
                        seenIds.add(a.id);
                        return true;
                      }).toList();

                      // If selected account no longer exists, reset it
                      if (_selectedAccountId != null &&
                          !accounts.any((a) => a.id == _selectedAccountId)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _selectedAccountId = null;
                          });
                        });
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAccountId,
                            hint: Text(
                              "Select Account",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            isExpanded: true,
                            dropdownColor: AppColors.cardBackground,
                            icon: Icon(
                              PhosphorIcons.caretDown(
                                PhosphorIconsStyle.regular,
                              ),
                              color: AppColors.textSecondary,
                            ),
                            items: accounts.map((account) {
                              return DropdownMenuItem<String>(
                                value: account.id,
                                child: Text(
                                  account.title,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedAccountId = newValue;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Date Picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat.yMMMd().format(_selectedDate),
                              style: AppTextStyles.bodyLarge,
                            ),
                          ),
                          Icon(
                            PhosphorIcons.calendarBlank(
                              PhosphorIconsStyle.regular,
                            ),
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Notes Input
                  CustomTextField(
                    hintText: "Notes (optional)",
                    controller: _notesController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Save Button
                  CustomButton(
                    text: _isEditMode ? "Save Changes" : "Add $typeLabel",
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Income',
              isSelected: _selectedType == TransactionType.income,
              onTap: () {
                if (_selectedType != TransactionType.income) {
                  setState(() {
                    _selectedType = TransactionType.income;
                    _selectedCategoryId =
                        null; // Reset category when type changes
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Expense',
              isSelected: _selectedType == TransactionType.expense,
              onTap: () {
                if (_selectedType != TransactionType.expense) {
                  setState(() {
                    _selectedType = TransactionType.expense;
                    _selectedCategoryId =
                        null; // Reset category when type changes
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.textInverse
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
