import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubscriptionBasicInfoFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;

  const SubscriptionBasicInfoFields({
    super.key,
    required this.nameController,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomTextField(
          hintText: l10n.subscriptionNameHint,
          controller: nameController,
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          hintText: l10n.amount,
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
            ThousandsSeparatorInputFormatter(),
          ],
        ),
      ],
    );
  }
}
