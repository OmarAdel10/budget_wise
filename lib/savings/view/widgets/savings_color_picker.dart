import 'package:flutter/material.dart';

class SavingsColorPicker extends StatelessWidget {
  final ValueNotifier<int> selectedColorNotifier;
  final List<int> colorOptions;

  const SavingsColorPicker({
    super.key,
    required this.selectedColorNotifier,
    required this.colorOptions,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedColorNotifier,
      builder: (context, current, _) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colorOptions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => selectedColorNotifier.value = colorOptions[i],
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(colorOptions[i]),
                  shape: BoxShape.circle,
                  border: current == colorOptions[i]
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: current == colorOptions[i]
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
