import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

/// A reusable widget that displays a 4-dot passcode indicator.
class PasscodeIndicator extends StatelessWidget {
  /// The current length of the entered passcode.
  final int inputLength;

  /// The total number of dots to display. Defaults to 4.
  final int totalDots;

  const PasscodeIndicator({
    super.key,
    required this.inputLength,
    this.totalDots = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final isFilled = index < inputLength;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled ? AppColors.primaryAccent : AppColors.borderColor,
              width: 2,
            ),
            color: isFilled ? AppColors.primaryAccent : null,
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
