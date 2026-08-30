import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/data/services/search_service.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CategoryField extends StatelessWidget {
  final Color iconBackgroundColor;
  final ValueNotifier<String?> selectedCategoryIdNotifier;
  final ValueNotifier<TransactionType> selectedTypeNotifier;
  final ValueNotifier<String> titleNotifier;
  final ValueNotifier<IconData> iconNotifier;
  final ValueNotifier<bool> isSelectedNotifier;

  const CategoryField({
    super.key,
    required this.iconBackgroundColor,
    required this.selectedTypeNotifier,
    required this.selectedCategoryIdNotifier,
    required this.titleNotifier,
    required this.iconNotifier,
    required this.isSelectedNotifier,
  });

  void _onCategoryChange(
    IconData selectedIcon,
    String selectedTitle,
    bool isSelected,
    String? selectedCategoryId,
  ) {
    titleNotifier.value = selectedTitle;
    iconNotifier.value = selectedIcon;
    isSelectedNotifier.value = isSelected;
    selectedCategoryIdNotifier.value = selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categoryLabelOptional,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            BottomSheetService.pageRoute(
              child: (context) {
                final scrollController = PrimaryScrollController.of(context);
                return _CategoriesSelectionScreen(
                  onCategorySelect: _onCategoryChange,
                  selectedType: selectedTypeNotifier,
                  iconColor: iconBackgroundColor,
                  scrollController: scrollController,
                );
              },
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.all(
                Radius.circular(AppSpacing.radiusMd),
              ),
              border: Border.all(color: AppColors.borderColor, width: 0.2),
              boxShadow: [AppBoxShadow()],
            ),
            child: Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isSelectedNotifier,
                  builder: (context, isSelected, child) {
                    return Container(
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? iconBackgroundColor.withValues(alpha: 0.2)
                            : AppColors.cardBackground,
                        border: Border.all(
                          color: isSelected
                              ? iconBackgroundColor
                              : AppColors.borderColor,
                          width: 0.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ValueListenableBuilder<IconData>(
                        valueListenable: iconNotifier,
                        builder: (context, icon, child) {
                          return Icon(
                            icon,
                            color: isSelected
                                ? iconBackgroundColor
                                : AppColors.textSecondary,
                            size: 20,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                ValueListenableBuilder<String>(
                  valueListenable: titleNotifier,
                  builder: (context, text, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: isSelectedNotifier,
                      builder: (context, isSelected, child) {
                        return Text(
                          text,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        );
                      },
                    );
                  },
                ),
                const Spacer(),
                const Icon(
                  PhosphorIconsBold.caretRight,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesSelectionScreen extends StatefulWidget {
  final Function(IconData, String, bool, String?) onCategorySelect;
  final ValueNotifier<TransactionType> selectedType;
  final Color iconColor;
  final ScrollController scrollController;
  const _CategoriesSelectionScreen({
    required this.onCategorySelect,
    required this.selectedType,
    required this.iconColor,
    required this.scrollController,
  });

  @override
  State<_CategoriesSelectionScreen> createState() =>
      _CategoriesSelectionScreenState();
}

class _CategoriesSelectionScreenState
    extends State<_CategoriesSelectionScreen> {
  late final SearchService<CategoryModel> _searchService;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService<CategoryModel>(
      searchFieldsExtractor: (cat) => [cat.categoryTitle],
    );
    _syncCategories();
  }

  void _syncCategories() {
    final categories = context
        .read<CategoryBloc>()
        .state
        .categoriesList
        .where((cat) => cat.type == widget.selectedType.value && !cat.isSystem)
        .toList();
    _searchService.updateSource(categories);
  }

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetService.headerWithSearch(
              headerTitle: context.l10n.categories,
              searchHintText: context.l10n.searchCategories,
              searchController: _searchService.searchController,
            ),
            Expanded(
              child: CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  // Most Used Categories — hidden when search is active
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _searchService.queryNotifier,
                      builder: (context, query, _) {
                        if (query.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _MostUsedCategoriesSection(
                          iconColor: widget.iconColor,
                          selectedType: widget.selectedType,
                          onCategorySelect: widget.onCategorySelect,
                        );
                      },
                    ),
                  ),
                  // Text 'Others' — hidden when search is active
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _searchService.queryNotifier,
                      builder: (context, query, _) {
                        if (query.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            BottomSheetService.label(labelText: 'Others'),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        );
                      },
                    ),
                  ),
                  // Categories List — driven by SearchService
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder<List<CategoryModel>>(
                      valueListenable: _searchService.filteredListNotifier,
                      builder: (context, categories, _) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.4,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              children: [
                                ...categories.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final cat = entry.value;
                                  final isLastItem =
                                      index == categories.length - 1;
                                  final title = cat.categoryTitle
                                      .trim()
                                      .replaceAll('_', ' ')
                                      .replaceAll(RegExp(r'\b(and)\b'), '&')
                                      .toTitleCase();
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          widget.onCategorySelect(
                                            cat.categoryIcon,
                                            title,
                                            true,
                                            cat.id,
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: _CategoryItem(
                                          categoryName: title,
                                          icon: cat.categoryIcon,
                                          iconColor: widget.iconColor,
                                        ),
                                      ),
                                      if (!isLastItem)
                                        const Divider(
                                          color: AppColors.borderColor,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: AppSpacing.lg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String categoryName;
  final Color iconColor;
  const _CategoryItem({
    required this.icon,
    required this.categoryName,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            border: Border.all(color: iconColor, width: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(categoryName, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}

class _MostUsedCategoriesSection extends StatelessWidget {
  final Color iconColor;
  final ValueNotifier<TransactionType> selectedType;
  final Function(IconData, String, bool, String?) onCategorySelect;

  const _MostUsedCategoriesSection({
    required this.iconColor,
    required this.selectedType,
    required this.onCategorySelect,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        final usageCount = <String, int>{};
        for (final t in txState.transactionsList) {
          if (t.type == selectedType.value) {
            usageCount[t.categoryId] = (usageCount[t.categoryId] ?? 0) + 1;
          }
        }

        return BlocSelector<CategoryBloc, CategoryState, List<CategoryModel>>(
          selector: (state) => state.categoriesList,
          builder: (context, categories) {
            final matching =
                categories
                    .where((c) => c.type == selectedType.value && !c.isSystem)
                    .toList()
                  ..sort(
                    (a, b) => (usageCount[b.id] ?? 0).compareTo(
                      usageCount[a.id] ?? 0,
                    ),
                  );

            final mostUsed = matching
                .where((c) => (usageCount[c.id] ?? 0) > 0)
                .take(5)
                .toList();

            if (mostUsed.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomSheetService.label(labelText: context.l10n.mostUsed),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.4,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      children: mostUsed.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cat = entry.value;
                        final isLastItem = index == mostUsed.length - 1;
                        final title = cat.categoryTitle
                            .trim()
                            .replaceAll('_', ' ')
                            .replaceAll(RegExp(r'\b(and)\b'), '&')
                            .toTitleCase();
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                onCategorySelect(
                                  cat.categoryIcon,
                                  title,
                                  true,
                                  cat.id,
                                );
                                Navigator.of(context).pop();
                              },
                              child: _CategoryItem(
                                categoryName: title,
                                icon: cat.categoryIcon,
                                iconColor: iconColor,
                              ),
                            ),
                            if (!isLastItem)
                              const Divider(color: AppColors.borderColor),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        );
      },
    );
  }
}
