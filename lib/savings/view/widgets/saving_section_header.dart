import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onJumpPressed;
  final String? tooltip;
  final IconData? icon;
  final GlobalKey? headerKey;
  final Color? titleColor;

  const SavingSectionHeader({
    super.key,
    required this.title,
    this.onJumpPressed,
    this.tooltip,
    this.icon,
    this.headerKey,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            key: headerKey,
            style: AppTextStyles.heading3.copyWith(color: titleColor),
          ),
          if (onJumpPressed != null)
            IconButton(
              icon: Icon(icon ?? Icons.arrow_downward,
                  color: AppColors.primaryAccent),
              onPressed: onJumpPressed,
              tooltip: tooltip,
            ),
        ],
      ),
    );
  }
}
