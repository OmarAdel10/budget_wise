import 'package:budget_wise/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ValidationIcon extends StatelessWidget {
  final bool isValid;
  final String text;

  const ValidationIcon({super.key, required this.isValid, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Icon(
      isValid ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.xCircle,
      color: isValid ? AppColors.primaryAccent : AppColors.danger,
    );
  }
}
