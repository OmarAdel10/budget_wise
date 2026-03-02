import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LinkMoreAccountsButton extends StatelessWidget {
  const LinkMoreAccountsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AddAccountScreen.routeName);
          },
          child: DottedBorder(
            options: const RoundedRectDottedBorderOptions(
              radius: Radius.circular(AppSpacing.radiusLg),
              dashPattern: [10, 5],
              strokeWidth: 1,
              padding: EdgeInsets.all(16),
              color: AppColors.borderColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.linkMoreAccounts,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
