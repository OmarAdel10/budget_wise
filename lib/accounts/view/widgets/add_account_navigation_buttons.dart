import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddAccountNavigationButtons extends StatelessWidget {
  const AddAccountNavigationButtons({
    super.key,
    required this.showCardEntry,
    required this.isPart2Enabled,
    required this.onSaveCard,
    required this.onAddAccountTap,
  });

  final ValueNotifier<bool> showCardEntry;
  final ValueNotifier<bool> isPart2Enabled;
  final VoidCallback onSaveCard;
  final VoidCallback onAddAccountTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: showCardEntry,
      builder: (context, showCardEntryValue, _) {
        return Row(
          children: [
            if (showCardEntryValue) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showCardEntry.value = false,
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
                      Icon(PhosphorIcons.arrowLeft(), color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.back,
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
                              ? (l10n.addAccountButtonSaveCard)
                              : isPart2EnabledValue
                              ? (l10n.continueWord)
                              : (l10n.addAccountButtonAddAccount),
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showCardEntryValue
                              ? PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.fill,
                                )
                              : isPart2EnabledValue
                              ? PhosphorIcons.arrowCircleRight(
                                  PhosphorIconsStyle.fill,
                                )
                              : PhosphorIcons.plusCircle(
                                  PhosphorIconsStyle.fill,
                                ),
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
