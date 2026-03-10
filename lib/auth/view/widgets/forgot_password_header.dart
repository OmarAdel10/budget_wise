import 'package:flutter/material.dart';
import '../../../../shared/constants/text_styles.dart';

class ForgotPasswordHeader extends StatelessWidget {
  final String title;

  const ForgotPasswordHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading2,
      textAlign: TextAlign.center,
    );
  }
}
