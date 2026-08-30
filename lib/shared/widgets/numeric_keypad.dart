import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
              width: 75,
              height: 70,
              child: leftButton != null ? _KeyWrapper(child: leftButton!) : null,
            ),
            _NumericKey(
              label: '0',
              onPressed: () => onDigitPressed('0'),
            ),
            _NumericKey(
              label: 'backspace',
              isIcon: true,
              onPressed: onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          labels
              .map(
                (label) => _NumericKey(
                  label: label,
                  onPressed: () => onDigitPressed(label),
                ),
              )
              .toList(),
    );
  }
}

class _NumericKey extends StatefulWidget {
  final String label;
  final bool isIcon;
  final VoidCallback onPressed;

  const _NumericKey({
    required this.label,
    this.isIcon = false,
    required this.onPressed,
  });

  @override
  State<_NumericKey> createState() => _NumericKeyState();
}

class _NumericKeyState extends State<_NumericKey> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 75,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child:
                    widget.isIcon && widget.label == 'backspace'
                        ? const Icon(
                          PhosphorIconsRegular.backspace,
                          color: AppColors.textPrimary,
                          size: 28,
                        )
                        : Text(
                          widget.label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyWrapper extends StatelessWidget {
  final Widget child;
  const _KeyWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: child),
    );
  }
}
