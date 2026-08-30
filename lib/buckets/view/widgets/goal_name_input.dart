import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/widgets/custom_text_field.dart';

class GoalNameInput extends StatelessWidget {
  final TextEditingController controller;

  const GoalNameInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: context.l10n.goalName,
      controller: controller,
      validator: (v) => v!.isEmpty ? context.l10n.nameRequired : null,
    );
  }
}
