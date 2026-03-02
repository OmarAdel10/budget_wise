import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryDropdown extends StatelessWidget {
  final ValueNotifier<TransactionType> selectedType;
  final ValueNotifier<String?> selectedCategoryId;

  const CategoryDropdown({
    super.key,
    required this.selectedType,
    required this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return ValueListenableBuilder2<TransactionType, String?>(
          first: selectedType,
          second: selectedCategoryId,
          builder: (context, type, categoryId, _) {
            final categories = state.categoriesList
                .where((c) => c.type == type)
                .toList();

            // Auto-reset if the selected category doesn't match the new type
            if (categoryId != null &&
                !categories.any((c) => c.id == categoryId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                selectedCategoryId.value = null;
              });
            }

            return Container(
              height: AppConstants.textFieldAndRelatedWidgetsHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md,),
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
                          const SizedBox(width: AppSpacing.md,),
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
          },
        );
      },
    );
  }
}

// Simple helper to listen to two values
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, _) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}
