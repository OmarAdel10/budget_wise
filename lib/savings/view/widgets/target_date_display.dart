import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TargetDateDisplay extends StatelessWidget {
  final ValueNotifier<DateTime> targetDateNotifier;
  final ValueNotifier<bool> isByAmountNotifier;
  final ValueNotifier<SavingsMethod> selectedMethodNotifier;
  final Future<void> Function() onPickDate;

  const TargetDateDisplay({
    super.key,
    required this.targetDateNotifier,
    required this.isByAmountNotifier,
    required this.selectedMethodNotifier,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        targetDateNotifier,
        isByAmountNotifier,
        selectedMethodNotifier,
      ]),
      builder: (context, _) {
        final isInteractive =
            isByAmountNotifier.value &&
            selectedMethodNotifier.value == SavingsMethod.custom;

        return InkWell(
          onTap: isInteractive ? onPickDate : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: RepaintBoundary(
            child: Opacity(
              opacity: isInteractive ? 1.0 : 0.6,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      DateFormat.yMMMd().format(targetDateNotifier.value),
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
