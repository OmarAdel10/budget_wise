import 'package:budget_wise/accounts/view/widgets/wallet_provider_bottom_sheet.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountWalletProviderField extends StatelessWidget {
  const AccountWalletProviderField({
    super.key,
    required this.l10n,
    required this.selectedProvider,
    required this.onProviderSelected,
  });

  final AppLocalizations l10n;
  final ValueNotifier<String?> selectedProvider;
  final Function(String providerName) onProviderSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAccountProviderLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<String?>(
            valueListenable: selectedProvider,
            builder: (context, providerName, _) {
              return FormField<String>(
                initialValue: providerName,
                key: ValueKey(providerName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.providerCantLeftEmpty;
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
                            builder: (context) => WalletProviderBottomSheet(
                              onProviderSelected: (name) {
                                onProviderSelected(name);
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
                                providerName ?? l10n.addAccountProviderPlaceholder,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: providerName == null
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
