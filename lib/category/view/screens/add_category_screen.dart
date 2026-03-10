import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/category/view/widgets/budget_section.dart';
import 'package:budget_wise/category/view/widgets/icon_section.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
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

  late final ValueNotifier<IconData> _selectedIcon;
  late final ValueNotifier<TransactionType> _selectedType;
  late final ValueNotifier<bool> _hasBudgetAmount;

  bool get _isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final cat = widget.categoryToEdit!;
      _nameController.text = cat.categoryTitle;
      _budgetController.text = cat.budgetAmount?.toStringAsFixed(0) ?? '';
      _selectedIcon = ValueNotifier(cat.categoryIcon);
      _selectedType = ValueNotifier(cat.type);
      _hasBudgetAmount = ValueNotifier(cat.hasBudgetAmount);
    } else {
      _selectedIcon = ValueNotifier(
        PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill),
      );
      _selectedType = ValueNotifier(TransactionType.expense);
      _hasBudgetAmount = ValueNotifier(false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _selectedIcon.dispose();
    _selectedType.dispose();
    _hasBudgetAmount.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final budgetText = _budgetController.text.replaceAll(',', '').trim();
    final hasBudget = _hasBudgetAmount.value;
    final budget = hasBudget ? double.tryParse(budgetText) : null;
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: l10n.enterCategoryName,
      );
      return;
    }

    if (hasBudget && (budget == null || budget <= 0)) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: l10n.enterValidBudget,
      );
      return;
    }

    if (_isEditMode) {
      final updatedCategory = widget.categoryToEdit!.copyWith(
        categoryTitle: name,
        categoryIcon: _selectedIcon.value,
        budgetAmount: budget,
        hasBudgetAmount: hasBudget,
        type: _selectedType.value,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      context.read<CategoryBloc>().add(
        CategoryEventUpdateCategory(updatedCategory),
      );
    } else {
      final newCategory = CategoryModel(
        categoryTitle: name,
        categoryIcon: _selectedIcon.value,
        budgetAmount: budget,
        hasBudgetAmount: hasBudget,
        type: _selectedType.value,
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
            _selectedIcon.value = icon;
          },
        ),
      ),
    );
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
          _isEditMode ? l10n.editCategory : l10n.addCategory,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<TransactionType>(
          valueListenable: _selectedType,
          builder: (context, type, _) {
            final accentColor = type == TransactionType.income
                ? AppColors.primaryAccent
                : AppColors.expense;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconSection(
                    selectedIcon: _selectedIcon,
                    onTap: _showIconPicker,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TransactionTypeToggle(
                    accentColor: accentColor,
                    selectedType: _selectedType,
                    incomeLabel: l10n.income,
                    expenseLabel: l10n.expenses,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.categoryName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    hintText: l10n.shoppingExample,
                    controller: _nameController,
                    activeColor: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BudgetSection(
                    selectedType: _selectedType,
                    hasBudgetAmount: _hasBudgetAmount,
                    budgetController: _budgetController,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomButton(
                    text: _isEditMode ? l10n.saveChanges : l10n.createCategory,
                    onPressed: _onSave,
                    color: accentColor,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
