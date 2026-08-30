import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AddAccountNavigationButtons extends StatelessWidget {
  const AddAccountNavigationButtons({
    super.key,
    required this.showCardEntry,
    required this.isPart2Enabled,
    required this.onSaveCard,
    required this.onAddAccountTap,
    this.onBack,
  });

  final ValueNotifier<bool> showCardEntry;
  final ValueNotifier<bool> isPart2Enabled;
  final VoidCallback onSaveCard;
  final VoidCallback onAddAccountTap;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showCardEntry,
      builder: (context, showCardEntryValue, _) {
        return Row(
          children: [
            if (showCardEntryValue) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: onBack ?? () => showCardEntry.value = false,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.arrowLeft, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.back,
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: showCardEntryValue ? onSaveCard : onAddAccountTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isPart2Enabled,
                  builder: (context, isPart2EnabledValue, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          showCardEntryValue
                              ? (context.l10n.addAccountButtonSaveCard.contains('Card') || context.l10n.addAccountButtonSaveCard.contains('بطاقة')
                                  ? (onSaveCard.toString().contains('_onSaveWallet') ? context.l10n.addAccountButtonSaveWallet : context.l10n.addAccountButtonSaveCard)
                                  : context.l10n.addAccountButtonSaveCard)
                              : isPart2EnabledValue
                              ? (context.l10n.continueWord)
                              : (context.l10n.addAccountButtonAddAccount),
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showCardEntryValue
                              ? PhosphorIconsFill.checkCircle
                              : isPart2EnabledValue
                              ? PhosphorIconsFill.arrowCircleRight
                              : PhosphorIconsFill.plusCircle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
