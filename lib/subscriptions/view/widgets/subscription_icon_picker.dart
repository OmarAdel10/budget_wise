import 'package:flutter/material.dart';

class SubscriptionIconPicker extends StatelessWidget {
  final ValueNotifier<IconData> iconNotifier;
  final ValueNotifier<Color> colorNotifier;
  final VoidCallback onTap;

  const SubscriptionIconPicker({
    super.key,
    required this.iconNotifier,
    required this.colorNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RepaintBoundary(
          child: ValueListenableBuilder<Color>(
            valueListenable: colorNotifier,
            builder: (context, color, _) {
              return ValueListenableBuilder<IconData>(
                valueListenable: iconNotifier,
                builder: (context, icon, _) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: color),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
