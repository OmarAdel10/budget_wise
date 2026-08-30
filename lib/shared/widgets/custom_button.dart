import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

enum CustomButtonType { primary, secondary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color? color;
  final double? height;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.leftIcon,
    this.rightIcon,
    this.color,
    this.height,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        color ??
        (type == CustomButtonType.primary
            ? AppColors.primaryAccent
            : AppColors.cardBackground);

    final textColor = type == CustomButtonType.primary
        ? AppColors.textInverse
        : AppColors.textPrimary;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: borderRadius != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(borderRadius!),
                )
              : null,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leftIcon != null) ...[
                    leftIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(color: textColor),
                  ),
                  if (rightIcon != null) ...[
                    const SizedBox(width: 8),
                    rightIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
