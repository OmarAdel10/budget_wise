import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

/// A reusable widget that displays a 4-dot passcode indicator.
class PasscodeIndicator extends StatelessWidget {
  /// The current length of the entered passcode.
  final int inputLength;

  /// The total number of dots to display. Defaults to 4.
  final int totalDots;

  /// Whether the indicator is in an error state (e.g. wrong passcode).
  final bool isError;

  /// Whether the indicator is in a success state.
  final bool isSuccess;

  /// The size of each dot.
  final double size;

  const PasscodeIndicator({
    super.key,
    required this.inputLength,
    this.totalDots = 4,
    this.isError = false,
    this.isSuccess = false,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final isFilled = index < inputLength;
        Color borderColor = AppColors.borderColor;
        Color? fillColor;

        if (isError) {
          borderColor = AppColors.danger;
          if (isFilled) fillColor = AppColors.danger;
        } else if (isSuccess) {
          borderColor = Colors.green;
          if (isFilled) fillColor = Colors.green;
        } else if (isFilled) {
          borderColor = AppColors.primaryAccent;
          fillColor = AppColors.primaryAccent;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            color: fillColor,
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: (fillColor ?? AppColors.primaryAccent).withValues(
                        alpha: 0.5,
                      ),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
