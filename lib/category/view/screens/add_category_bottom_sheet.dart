import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view/widgets/budget_section.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:budget_wise/shared/widgets/icon_picker_bottom_sheet.dart';
import 'package:budget_wise/shared/widgets/type_tab_bar.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  final CategoryModel? categoryToEdit;

  const AddCategoryBottomSheet({super.key, this.categoryToEdit});

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final ValueNotifier<bool> canSaveNotifier = ValueNotifier<bool>(true);

  late final ValueNotifier<IconData> _selectedIcon;
  late final ValueNotifier<TransactionType> _selectedType;
  late final ValueNotifier<bool> _hasBudgetAmount;

  bool get _isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_nameFocusNode.canRequestFocus) {
      _nameFocusNode.requestFocus();
    }
    if (_isEditMode) {
      final cat = widget.categoryToEdit!;
      _nameController.text = cat.categoryTitle;
      _budgetController.text = cat.budgetAmount?.toStringAsFixed(0) ?? '';
      _selectedIcon = ValueNotifier(cat.categoryIcon);
      _selectedType = ValueNotifier(cat.type);
      _hasBudgetAmount = ValueNotifier(cat.hasBudgetAmount);
    } else {
      _selectedIcon = ValueNotifier(PhosphorIconsFill.shoppingBag);
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

    if (name.isEmpty) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: context.l10n.enterCategoryName,
      );
      canSaveNotifier.value = false;
      return;
    }

    if (hasBudget && (budget == null || budget <= 0)) {
      AppToast.show(
        context,
        type: AppToastType.error,
        title: context.l10n.enterValidBudget,
      );
      canSaveNotifier.value = false;
      return;
    }

    canSaveNotifier.value = true;

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
    AppToast.show(
      context,
      type: AppToastType.success,
      title: context.l10n.categorySavedSuccessfully,
    );
    Navigator.of(context).pop();
  }

  void _showIconPicker() {
    Navigator.of(context).push(
      BottomSheetService.pageRoute(
        child: (context) => IconPickerBottomSheet(
          onIconSelected: (icon) {
            _selectedIcon.value = icon;
          },
          accentColor: _selectedType.value == TransactionType.transfer
              ? AppColors.transfer
              : _selectedType.value == TransactionType.income
              ? AppColors.income
              : AppColors.expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ValueListenableBuilder<TransactionType>(
        valueListenable: _selectedType,
        builder: (context, type, _) {
          final accentColor = type == TransactionType.transfer
              ? AppColors.transfer
              : type == TransactionType.income
              ? AppColors.income
              : AppColors.expense;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomSheetService.header(
                title: _isEditMode
                    ? context.l10n.editCategory
                    : context.l10n.addCategory,
                actions: [
                  GestureDetector(
                    onTap: _onSave,
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
              GenericIconContainer(
                selectedIcon: _selectedIcon,
                color: accentColor,
                isSelectable: true,
                iconSize: 45,
                onTap: _showIconPicker,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: TypeTabBar.forTransactionTypes(
                      selectionNotifier: _selectedType,
                      padding: EdgeInsets.zero,
                      isScrollable: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                label: context.l10n.categoryName,
                hintText: context.l10n.shoppingExample,
                controller: _nameController,
                focusNode: _nameFocusNode,
                shouldUnfocusOnTapOutside: true,
                hasOriginalInputDecoration: false,
              ),
              const SizedBox(height: AppSpacing.lg),
              BudgetSection(
                selectedType: _selectedType,
                hasBudgetAmount: _hasBudgetAmount,
                budgetController: _budgetController,
              ),
            ],
          );
        },
      ),
    );
  }
}
