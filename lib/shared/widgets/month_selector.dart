import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            DateFormat.yMMMM(
              Localizations.localeOf(context).languageCode,
            ).format(selectedMonth),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
