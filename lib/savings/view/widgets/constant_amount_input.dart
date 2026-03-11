import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/shared/constants/spacing.dart';

class ConstantAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const ConstantAmountInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          hintText: l10n.dailySavingAmount,
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
