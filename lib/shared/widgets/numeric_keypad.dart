import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final Widget? leftButton;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.leftButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: AppSpacing.md),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: AppSpacing.md),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: leftButton ?? const SizedBox.shrink(),
            ),
            _buildKey('0'),
            _buildKey('backspace', isIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _buildKey(label)).toList(),
    );
  }

  Widget _buildKey(String label, {bool isIcon = false}) {
    return InkWell(
      onTap: () {
        if (isIcon && label == 'backspace') {
          onBackspacePressed();
        } else {
          onDigitPressed(label);
        }
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isIcon && label == 'backspace'
              ? const Icon(
                  PhosphorIconsRegular.backspace,
                  color: AppColors.textPrimary,
                  size: 28,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
      ),
    );
  }
}
