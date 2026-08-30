import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/widgets/type_tab_bar.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/transaction/data/models/merchant_category_mapping.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_bloc.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AddMerchantRuleScreen extends StatefulWidget {
  final MerchantCategoryMapping? existingRule;

  const AddMerchantRuleScreen({super.key, this.existingRule});

  bool get isEditMode => existingRule != null;

  @override
  State<AddMerchantRuleScreen> createState() => _AddMerchantRuleScreenState();
}

class _AddMerchantRuleScreenState extends State<AddMerchantRuleScreen> {
  late final TextEditingController _merchantNameController;
  late final ValueNotifier<TransactionType> _selectedTypeNotifier;
  late final ValueNotifier<ToggleOption> _tabSelectionNotifier;
  String? _selectedCategoryId;
  String _selectedCategoryTitle = '';

  bool get _isFormValid =>
      _merchantNameController.text.trim().isNotEmpty &&
      _selectedCategoryId != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRule;
    _merchantNameController = TextEditingController(
      text: existing?.merchantName ?? '',
    );
    _selectedTypeNotifier = ValueNotifier<TransactionType>(
      existing?.transactionType ?? TransactionType.expense,
    );
    _tabSelectionNotifier = ValueNotifier<ToggleOption>(
      _toggleOptionFromType(_selectedTypeNotifier.value),
    );
    _selectedCategoryId = existing?.categoryId;
    _selectedCategoryTitle = existing?.categoryTitle ?? '';
    _merchantNameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _merchantNameController.removeListener(_onFormChanged);
    _merchantNameController.dispose();
    _selectedTypeNotifier.dispose();
    _tabSelectionNotifier.dispose();
    super.dispose();
  }

  void _onCategorySelected(String categoryId, String categoryTitle) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryTitle = categoryTitle;
    });
  }

  void _onSave() {
    final name = _merchantNameController.text.trim();
    if (name.isEmpty || _selectedCategoryId == null) return;

    final bloc = context.read<MerchantCategoryLearningBloc>();

    if (widget.isEditMode) {
      // Delete old mapping first
      bloc.add(
        MerchantCategoryLearningEventMappingDeleted(
          id: widget.existingRule!.id,
        ),
      );
    }

    // Save the new mapping
    bloc.add(
      MerchantCategoryLearningEventMappingSaved(
        merchantName: name,
        categoryId: _selectedCategoryId!,
        categoryTitle: _selectedCategoryTitle,
        transactionType: _selectedTypeNotifier.value,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditMode
        ? context.l10n.editMerchantRule
        : context.l10n.addMerchantRule;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            BottomSheetService.header(title: title),
            const SizedBox(height: AppSpacing.xl),

            // Merchant Name TextField
            Text(
              context.l10n.merchantName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _merchantNameController,
              decoration: InputDecoration(
                hintText: context.l10n.merchantNameHint,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                    width: 0.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                    width: 0.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primaryAccent,
                    width: 1.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Category Selection Label
            Text(
              context.l10n.selectCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab bar and category list
            Expanded(
              child: TypeTabBar.forToggleOptions(
                isScrollable: false,
                padding: EdgeInsets.zero,
                options: const [
                  ToggleOption.expense,
                  ToggleOption.income,
                  ToggleOption.transfer,
                ],
                selectionNotifier: _tabSelectionNotifier,
                onChanged: (option) {
                  _selectedTypeNotifier.value = _typeFromToggleOption(option);
                },
                views: [
                  _CategoryListView(
                    type: TransactionType.expense,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                  ),
                  _CategoryListView(
                    type: TransactionType.income,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                  ),
                  _CategoryListView(
                    type: TransactionType.transfer,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                  ),
                ],
              ),
            ),

            // Save Button
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isFormValid ? _onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  disabledBackgroundColor: AppColors.primaryAccent.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(
                  context.l10n.saveRule,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ToggleOption _toggleOptionFromType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return ToggleOption.expense;
      case TransactionType.income:
        return ToggleOption.income;
      case TransactionType.transfer:
        return ToggleOption.transfer;
    }
  }

  TransactionType _typeFromToggleOption(ToggleOption option) {
    switch (option) {
      case ToggleOption.expense:
        return TransactionType.expense;
      case ToggleOption.income:
        return TransactionType.income;
      case ToggleOption.transfer:
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}

class _CategoryListView extends StatelessWidget {
  final TransactionType type;
  final String? selectedCategoryId;
  final Function(String categoryId, String categoryTitle) onCategorySelected;

  const _CategoryListView({
    required this.type,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CategoryBloc, CategoryState, List<CategoryModel>>(
      selector: (state) => state.categoriesList,
      builder: (context, categories) {
        final filtered = categories
            .where((cat) => cat.type == type && !cat.isSystem)
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              context.l10n.noMerchantRules,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          separatorBuilder: (_, _) =>
              const Divider(color: AppColors.borderColor),
          itemBuilder: (context, index) {
            final cat = filtered[index];
            final isSelected = cat.id == selectedCategoryId;
            final title = cat.categoryTitle
                .trim()
                .replaceAll('_', ' ')
                .replaceAll(RegExp(r'\b(and)\b'), '&')
                .toTitleCase();

            return _SelectableCategoryItem(
              icon: cat.categoryIcon,
              categoryName: title,
              isSelected: isSelected,
              type: type,
              onTap: () => onCategorySelected(cat.id, title),
            );
          },
        );
      },
    );
  }
}

class _SelectableCategoryItem extends StatelessWidget {
  final IconData icon;
  final String categoryName;
  final bool isSelected;
  final TransactionType type;
  final VoidCallback onTap;

  const _SelectableCategoryItem({
    required this.icon,
    required this.categoryName,
    required this.isSelected,
    required this.type,
    required this.onTap,
  });

  Color get _typeColor {
    switch (type) {
      case TransactionType.income:
        return AppColors.primaryAccent;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Icon container with selection border
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? _typeColor.withValues(alpha: 0.2)
                    : AppColors.cardBackground,
                border: Border.all(
                  color: isSelected ? _typeColor : AppColors.borderColor,
                  width: isSelected ? 1.5 : 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? _typeColor : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Category name
            Expanded(
              child: Text(
                categoryName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            // Check icon when selected
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsBold.check,
                  color: AppColors.textPrimary,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
