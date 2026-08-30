import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class SavingGoalColorPicker extends StatelessWidget {
  final ValueNotifier<Color> selectedColorNotifier;

  const SavingGoalColorPicker({super.key, required this.selectedColorNotifier});

  static final List<int> colorOptions = [
    0xFF4CAF50,
    0xFF2196F3,
    0xFFFFC107,
    0xFFE91E63,
    0xFF9C27B0,
    0xFFFF5722,
    0xFF00BCD4,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.selectColor,
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<Color>(
          valueListenable: selectedColorNotifier,
          builder: (context, current, _) {
            return SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: colorOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () =>
                      selectedColorNotifier.value = Color(colorOptions[i]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(colorOptions[i]),
                      shape: BoxShape.circle,
                      border: current == Color(colorOptions[i])
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: current == Color(colorOptions[i])
                          ? [
                              BoxShadow(
                                color: Color(
                                  colorOptions[i],
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: current == Color(colorOptions[i])
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
