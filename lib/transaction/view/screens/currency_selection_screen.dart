import 'package:budget_wise/accounts/data/data_source/account_constants.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CurrencySelectionScreen extends StatelessWidget {
  final ScrollController scrollController;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelect;

  const CurrencySelectionScreen({
    super.key,
    required this.scrollController,
    required this.selectedCurrency,
    required this.onCurrencySelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // Title + Back Button
            SliverToBoxAdapter(
              child: BottomSheetService.header(
                title: context.l10n.selectCurrency,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderColor, width: 0.4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      ...AccountConstants.supportedCurrencies.entries.map((entry) {
                        final flag = entry.key;
                        final currencyMap = entry.value;
                        final code = currencyMap.keys.first;
                        final name = currencyMap.values.first;
                        final isSelected = code == selectedCurrency;
                        final isLastItem = entry.key == AccountConstants.supportedCurrencies.keys.last;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                onCurrencySelect(code);
                                Navigator.of(context).pop();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: _CurrencyItem(
                                flag: flag,
                                code: code,
                                name: name,
                                isSelected: isSelected,
                              ),
                            ),
                            if (!isLastItem)
                              const Divider(
                                color: AppColors.borderColor,
                                indent: AppSpacing.xl * 2,
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final String flag;
  final String code;
  final String name;
  final bool isSelected;

  const _CurrencyItem({
    required this.flag,
    required this.code,
    required this.name,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryAccent.withValues(alpha: 0.1)
                  : AppColors.cardBackground,
              border: Border.all(
                color: isSelected ? AppColors.primaryAccent : AppColors.borderColor,
                width: 0.5,
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                  ),
                ),
                Text(
                  code,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              PhosphorIconsFill.checkCircle,
              color: AppColors.primaryAccent,
              size: 20,
            ),
        ],
      ),
    );
  }
}
