import 'package:flutter/material.dart';
import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategorySelectionPage extends StatefulWidget {
  final Function(List<CategoryModel> selectedCategories) onSelectionChanged;

  const CategorySelectionPage({super.key, required this.onSelectionChanged});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<String> _selectedCategories = [];

  // Map of category keys to icons
  final Map<String, IconData> _categoryIcons = {
    'Smoking': PhosphorIconsRegular.fire,
    'Eating': PhosphorIconsRegular.forkKnife,
    'Transport': PhosphorIconsRegular.car,
    'Utils': PhosphorIconsRegular.lightbulb,
    'Debts': PhosphorIconsRegular.creditCard,
    'Investments': PhosphorIconsRegular.chartLineUp,
    'Mobile': PhosphorIconsRegular.phone,
    'Rent': PhosphorIconsRegular.house,
    'Health': PhosphorIconsRegular.firstAid,
    'Entertainment': PhosphorIconsRegular.filmSlate,
    'Education': PhosphorIconsRegular.graduationCap,
    'Groceries': PhosphorIconsRegular.shoppingCart,
  };

  void _toggleCategory(String categoryKey) {
    setState(() {
      if (_selectedCategories.contains(categoryKey)) {
        _selectedCategories.remove(categoryKey);
      } else {
        _selectedCategories.add(categoryKey);
      }
      
      final selectedModels = _selectedCategories.map((key) {
        return CategoryModel(
          categoryTitle: key,
          categoryIcon: _categoryIcons[key]!,
          budgetAmount: 0.0,
          type: TransactionType.expense,
        );
      }).toList();

      widget.onSelectionChanged(selectedModels);
    });
  }

  String _getLocalizedCategoryName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'Smoking': return l10n.catSmoking;
      case 'Eating': return l10n.catEating;
      case 'Transport': return l10n.catTransport;
      case 'Utils': return l10n.catUtils;
      case 'Debts': return l10n.catDebts;
      case 'Investments': return l10n.catInvestments;
      case 'Mobile': return l10n.catMobile;
      case 'Rent': return l10n.catRent;
      case 'Health': return l10n.catHealth;
      case 'Entertainment': return l10n.catEntertainment;
      case 'Education': return l10n.catEducation;
      case 'Groceries': return l10n.catGroceries;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.categorySelectionTitle,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.categorySelectionDesc,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.builder(
              itemCount: _categoryIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final categoryKey = _categoryIcons.keys.elementAt(index);
                final icon = _categoryIcons[categoryKey]!;
                final isSelected = _selectedCategories.contains(categoryKey);

                return GestureDetector(
                  onTap: () => _toggleCategory(categoryKey),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryAccent.withValues(alpha: 0.2) : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryAccent : AppColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 32,
                          color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            _getLocalizedCategoryName(context, categoryKey),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
