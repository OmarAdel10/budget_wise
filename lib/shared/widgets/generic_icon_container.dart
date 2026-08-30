import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../constants/spacing.dart';

class GenericIconContainer extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final double backgroundOpacity;
  final double borderOpacity;
  final bool isSelectable;
  final VoidCallback? onTap;
  final ValueNotifier<IconData>? selectedIcon;

  const GenericIconContainer({
    super.key,
    this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = AppSpacing.radiusMd,
    this.backgroundOpacity = 0.1,
    this.borderOpacity = 0.2,
    this.isSelectable = false,
    this.onTap,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconContainer = Container(
      width: isSelectable ? 70 : size,
      height: isSelectable ? 70 : size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity.clamp(0, 1)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: borderOpacity.clamp(0, 1)),
        ),
      ),
      child: isSelectable
          ? ValueListenableBuilder(
              valueListenable: selectedIcon!,
              builder: (context, value, child) {
                return Icon(value, color: color, size: iconSize);
              },
            )
          : Icon(
              icon ?? PhosphorIconsBold.exclamationMark,
              color: color,
              size: iconSize,
            ),
    );

    if (isSelectable) {
      return Column(
        children: [
          GestureDetector(onTap: onTap, child: iconContainer),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              context.l10n.tapToChangeIcon,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return iconContainer;
  }
}
