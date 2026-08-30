import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/data/services/search_service.dart';
import 'package:budget_wise/shared/utils/delete_dialog.dart';
import 'package:budget_wise/transaction/data/models/merchant_category_mapping.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/add_merchant_rule_screen.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_bloc.dart';
import 'package:budget_wise/transaction/view_model/merchant_category_learning_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class MerchantRulesBottomSheet extends StatefulWidget {
  const MerchantRulesBottomSheet({super.key});

  @override
  State<MerchantRulesBottomSheet> createState() =>
      _MerchantRulesBottomSheetState();
}

class _MerchantRulesBottomSheetState extends State<MerchantRulesBottomSheet> {
  final GlobalKey<NavigatorState> _navStateKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        return Container(
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
              child: (context) => _MerchantRulesBottomSheetContent(
                controller: scrollController,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MerchantRulesBottomSheetContent extends StatefulWidget {
  final ScrollController controller;
  const _MerchantRulesBottomSheetContent({required this.controller});

  @override
  State<_MerchantRulesBottomSheetContent> createState() =>
      _MerchantRulesBottomSheetContentState();
}

class _MerchantRulesBottomSheetContentState
    extends State<_MerchantRulesBottomSheetContent> {
  late final SearchService<MerchantCategoryMapping> _searchService;

  @override
  void initState() {
    super.initState();
    context.read<MerchantCategoryLearningBloc>().add(
      const MerchantCategoryLearningEventLoadRequested(),
    );

    _searchService = SearchService<MerchantCategoryMapping>(
      searchFieldsExtractor: (m) => [m.merchantName, m.categoryTitle],
    );

    // Sync search source whenever the BLoC emits new state.
    context.read<MerchantCategoryLearningBloc>().stream.listen((state) {
      if (mounted) {
        _searchService.updateSource(state.mappings);
      }
    });
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetService.header(
              title: context.l10n.merchantRules,
              isRoot: true,
              actions: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    BottomSheetService.pageRoute(
                      child: (context) => const AddMerchantRuleScreen(),
                    ),
                  ),
                  child: const Icon(
                    PhosphorIconsBold.plus,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            BottomSheetService.searchBar(
              hintText: context.l10n.searchByMerchantName,
              controller: _searchService.searchController,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ValueListenableBuilder<List<MerchantCategoryMapping>>(
                valueListenable: _searchService.filteredListNotifier,
                builder: (context, filtered, _) {
                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl * 2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              PhosphorIconsRegular.storefront,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ValueListenableBuilder<String>(
                              valueListenable: _searchService.queryNotifier,
                              builder: (context, query, _) {
                                return Text(
                                  query.isEmpty
                                      ? context.l10n.noMerchantRules
                                      : '${context.l10n.noMerchantRules}\n${context.l10n.noMerchantRulesDesc}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    controller: widget.controller,
                    separatorBuilder: (_, _) =>
                        const Divider(color: AppColors.borderColor),
                    itemBuilder: (context, index) {
                      final mapping = filtered[index];
                      return _MerchantRuleItem(
                        mapping: mapping,
                        onTap: () {
                          Navigator.of(context).push(
                            BottomSheetService.pageRoute(
                              child: (context) =>
                                  AddMerchantRuleScreen(existingRule: mapping),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(context, mapping),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantCategoryMapping mapping) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteDialog(
        deletingType: context.l10n.rule,
        onDelete: () {
          context.read<MerchantCategoryLearningBloc>().add(
            MerchantCategoryLearningEventMappingDeleted(id: mapping.id),
          );
        },
      ),
    );
  }
}

class _MerchantRuleItem extends StatelessWidget {
  final MerchantCategoryMapping mapping;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MerchantRuleItem({
    required this.mapping,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color typeColor = switch (mapping.transactionType) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.2),
                border: Border.all(color: typeColor, width: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsBold.storefront,
                color: typeColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapping.merchantName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    mapping.categoryTitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                PhosphorIconsRegular.trash,
                color: AppColors.danger,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
