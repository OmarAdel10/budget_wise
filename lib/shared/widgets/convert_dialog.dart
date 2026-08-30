import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

enum ConvertType { saving, subscription }

class ConvertDialog extends StatelessWidget {
  final VoidCallback onConvert;
  final VoidCallback onSaveTransaction;
  final ConvertType convertType;

  const ConvertDialog({
    super.key,
    required this.onConvert,
    required this.onSaveTransaction,
    required this.convertType,
  });

  String get _title {
    switch (convertType) {
      case ConvertType.saving:
        return 'Convert to Saving Goal?';
      case ConvertType.subscription:
        return 'Convert to Subscription?';
    }
  }

  String get _description {
    switch (convertType) {
      case ConvertType.saving:
        return 'Do you want to create a saving goal from this transaction?';
      case ConvertType.subscription:
        return 'Do you want to create a subscription from this transaction?';
    }
  }

  String get _convertLabel {
    switch (convertType) {
      case ConvertType.saving:
        return 'Create Goal';
      case ConvertType.subscription:
        return 'Create Subscription';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        minWidth: MediaQuery.sizeOf(context).width * 0.8,
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_title, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      elevation: 30,
      backgroundColor: AppColors.primaryBackground,
      alignment: Alignment.center,
      content: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: AppColors.borderColor),
            Column(
              children: [
                // Convert button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onConvert.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _convertLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                // Save as transaction button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSaveTransaction.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save as Transaction',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                // Cancel button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cancel',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
