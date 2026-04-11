import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TargetDaysInput extends StatelessWidget {
  final ValueNotifier<bool> isByAmountNotifier;
  final ValueNotifier<SavingsMethod> selectedMethodNotifier;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  const TargetDaysInput({
    super.key,
    required this.isByAmountNotifier,
    required this.selectedMethodNotifier,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([
        isByAmountNotifier,
        selectedMethodNotifier,
      ]),
      builder: (context, _) {
        final isByAmount = isByAmountNotifier.value;
        final selectedMethod = selectedMethodNotifier.value;
        final isInteractive =
            !isByAmount || selectedMethod == SavingsMethod.custom;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isInteractive ? 1.0 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.numberOfDays, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: l10n.enterDays,
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                readOnly: !isInteractive,
                bgColor: !isInteractive ? AppColors.secondaryBackground : null,
                onChanged: (_) => onChanged(),
              ),
            ],
          ),
        );
      },
    );
  }
}
