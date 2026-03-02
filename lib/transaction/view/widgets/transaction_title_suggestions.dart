import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class TransactionTitleSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String titleSelected) onTitleSelect;

  const TransactionTitleSuggestions({
    super.key,
    required this.suggestions,
    required this.onTitleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: MediaQuery.sizeOf(context).height * 0.2,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          final title = suggestions[index];
          return ListTile(
            minTileHeight: 0,
            minVerticalPadding: 5,
            title: Text(title, style: AppTextStyles.bodyMedium),
            onTap: () {
              onTitleSelect(title);
            },
          );
        },
        separatorBuilder: (_, index) =>
            const Divider(color: AppColors.borderColor),
        itemCount: suggestions.length,
      ),
    );
  }
}
