import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/utils/value_listenable_builders.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';

class CategoryDropdown extends StatelessWidget {
  final ValueNotifier<String?> selectedCategoryId;
  final ValueNotifier<TransactionType>? selectedTypeNotifier;
  final TransactionType? fixedType;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    this.selectedTypeNotifier,
    this.fixedType,
  }) : assert(
          selectedTypeNotifier != null || fixedType != null,
          'Either selectedTypeNotifier or fixedType must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (selectedTypeNotifier != null) {
          return ValueListenableBuilder2<TransactionType, String?>(
            first: selectedTypeNotifier!,
            second: selectedCategoryId,
            builder: (context, type, categoryId, _) {
              return _buildDropdown(context, state, type, categoryId, l10n);
            },
          );
        } else {
          return ValueListenableBuilder<String?>(
            valueListenable: selectedCategoryId,
            builder: (context, categoryId, _) {
              return _buildDropdown(
                context,
                state,
                fixedType!,
                categoryId,
                l10n,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    CategoryState state,
    TransactionType type,
    String? categoryId,
    AppLocalizations l10n,
  ) {
    final categories =
        state.categoriesList.where((c) => c.type == type).toList();

    // Auto-reset if the selected category doesn't match the new type
    if (categoryId != null && !categories.any((c) => c.id == categoryId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedCategoryId.value = null;
      });
    }

    return Container(
      height: AppConstants.textFieldAndRelatedWidgetsHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: categoryId,
          hint: Text(
            l10n.category,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          icon: const Icon(
            PhosphorIconsRegular.caretDown,
            color: AppColors.textSecondary,
          ),
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Row(
                children: [
                  Icon(cat.categoryIcon, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    cat.categoryTitle,
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            selectedCategoryId.value = newValue;
          },
        ),
      ),
    );
  }
}
