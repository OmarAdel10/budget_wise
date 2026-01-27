import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/icon_picker_bottom_sheet.dart';

class AddCategoryScreen extends StatefulWidget {
  static const String routeName = '/add-category';

  final CategoryModel? categoryToEdit;

  const AddCategoryScreen({super.key, this.categoryToEdit});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  late IconData _selectedIcon;
  late TransactionType _selectedType;
  late bool _hasBudgetAmount;

  bool get _isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final cat = widget.categoryToEdit!;
      _nameController.text = cat.categoryTitle;
      _budgetController.text = cat.budgetAmount?.toStringAsFixed(0) ?? '';
      _selectedIcon = cat.categoryIcon;
      _selectedType = cat.type;
      _hasBudgetAmount = cat.hasBudgetAmount;
    } else {
      _selectedIcon = PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill);
      _selectedType = TransactionType.expense;
      _hasBudgetAmount = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final budgetText = _budgetController.text.replaceAll(',', '').trim();
    final budget = _hasBudgetAmount ? double.tryParse(budgetText) : null;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (_hasBudgetAmount && (budget == null || budget <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    if (_isEditMode) {
      final updatedCategory = widget.categoryToEdit!.copyWith(
        categoryTitle: name,
        categoryIcon: _selectedIcon,
        budgetAmount: budget,
        hasBudgetAmount: _hasBudgetAmount,
        type: _selectedType,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      context.read<CategoryBloc>().add(
        CategoryEventUpdateCategory(updatedCategory),
      );
    } else {
      final newCategory = CategoryModel(
        categoryTitle: name,
        categoryIcon: _selectedIcon,
        budgetAmount: budget,
        hasBudgetAmount: _hasBudgetAmount,
        type: _selectedType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<CategoryBloc>().add(
        CategoryEventCreateCategory(newCategory),
      );
    }
    Navigator.of(context).pop();
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.5,
        child: IconPickerBottomSheet(
          onIconSelected: (icon) {
            setState(() {
              _selectedIcon = icon;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _isEditMode ? "Edit Category" : "Add Category",
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
              // Icon Selection
              Center(
                child: GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryAccent),
                    ),
                    child: Icon(
                      _selectedIcon,
                      size: 40,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  "Tap to change icon",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category Type Selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                            // Income categories typically don't have budgets
                            _hasBudgetAmount = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? AppColors.primaryAccent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedType == TransactionType.income
                                    ? Colors.black
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? AppColors.primaryAccent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedType == TransactionType.expense
                                    ? Colors.black
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name Input
              Text("Category Name", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: "e.g., Shopping",
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget Toggle (only for expense categories)
              if (_selectedType == TransactionType.expense) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Budget Limit",
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              "Track spending against a monthly budget",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Switch(
                        value: _hasBudgetAmount,
                        onChanged: (value) {
                          setState(() {
                            _hasBudgetAmount = value;
                            if (!value) {
                              _budgetController.clear();
                            }
                          });
                        },
                        activeThumbColor: AppColors.primaryAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Budget Input (only shown when toggle is on)
                if (_hasBudgetAmount) ...[
                  Text("Monthly Budget", style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    hintText: "Amount",
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    prefixIcon: Icon(
                      PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],

              const SizedBox(height: AppSpacing.md),

              // Save Button
              CustomButton(
                text: _isEditMode ? "Save Changes" : "Create Category",
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
