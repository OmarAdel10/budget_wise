import 'package:flutter/material.dart';
import '../constants/spacing.dart';

class GenericIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final double backgroundOpacity;
  final double borderOpacity;

  const GenericIconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = AppSpacing.radiusMd,
    this.backgroundOpacity = 0.1,
    this.borderOpacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withValues(alpha: borderOpacity)),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
