import 'package:budget_wise/accounts/view/widgets/bank_picker_bottom_sheet.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountBankNameField extends StatelessWidget {
  const AccountBankNameField({
    super.key,
    required this.l10n,
    required this.selectedBankName,
    required this.onBankSelected,
    this.hasPadding = true,
  });

  final AppLocalizations l10n;
  final ValueNotifier<String?> selectedBankName;
  final Function(String bankName, List<String>? senderIds) onBankSelected;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: hasPadding ? const EdgeInsets.all(AppSpacing.lg) : null,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAccountBankNameLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<String?>(
            valueListenable: selectedBankName,
            builder: (context, bankName, _) {
              return FormField<String>(
                initialValue: bankName,
                key: ValueKey(bankName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.bankNameCantLeftEmpty;
                  }
                  return null;
                },
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => BankPickerBottomSheet(
                              onBankSelected: (name, senderIds) {
                                onBankSelected(name, senderIds);
                                state.didChange(name);
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.sizeOf(context).height * .05,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            border: state.hasError
                                ? Border.all(color: AppColors.danger)
                                : null,
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bankName?.toTitleCase() ??
                                    l10n.addAccountBankNamePlaceholder,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: bankName == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Icon(
                                PhosphorIcons.caretDown(),
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            state.errorText ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
