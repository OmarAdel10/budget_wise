import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/home/view/widgets/secondry_button.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeRecentTransactionsHeader extends StatefulWidget {
  const HomeRecentTransactionsHeader({super.key});

  @override
  State<HomeRecentTransactionsHeader> createState() =>
      _HomeRecentTransactionsHeaderState();
}

class _HomeRecentTransactionsHeaderState
    extends State<HomeRecentTransactionsHeader> {
  late final ValueNotifier<bool> _showFilterNotifier;

  @override
  void initState() {
    super.initState();
    _showFilterNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _showFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      context.l10n.recentActivity,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showFilterNotifier,
                      builder: (context, showFilter, _) {
                        return GestureDetector(
                          onTap: () => _showFilterNotifier.value = !showFilter,
                          child: Icon(
                            showFilter
                                ? PhosphorIconsBold.funnelSimple
                                : PhosphorIconsRegular.funnelSimple,
                            size: 18,
                            color: showFilter
                                ? AppColors.primaryAccent
                                : AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    const SecondryButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showFilterNotifier,
          builder: (context, showFilter, _) {
            if (!showFilter) return const SizedBox.shrink();
            return const _CategoryTabBar();
          },
        ),
      ],
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  const _CategoryTabBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.model.categories != c.model.categories ||
          p.model.selectedCategoryId != c.model.selectedCategoryId,
      builder: (context, state) {
        final categories = state.model.categories;
        final selectedCategoryId = state.model.selectedCategoryId;

        return Container(
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryPill(
                  title: 'All',
                  isSelected: selectedCategoryId == null,
                  onTap: () => context.read<HomeBloc>().add(
                    const HomeEventFilterByCategory(null),
                  ),
                );
              }

              final categoryItem = categories[index - 1];
              final category = categoryItem.source as CategoryModel;
              return _CategoryPill(
                title: category.categoryTitle,
                isSelected: selectedCategoryId == category.id,
                onTap: () => context.read<HomeBloc>().add(
                  HomeEventFilterByCategory(category.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent
              : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.black : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
