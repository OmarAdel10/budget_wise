import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/widgets/custom_text_field.dart';

class GoalNameInput extends StatelessWidget {
  final TextEditingController controller;

  const GoalNameInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomTextField(
      hintText: l10n.goalName,
      controller: controller,
      validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
    );
  }
}
