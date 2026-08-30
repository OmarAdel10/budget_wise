import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NetWorthSection extends StatelessWidget {
  const NetWorthSection({super.key});

  @override
  Widget build(BuildContext context) {
    final netWorth = context.select<AccountBloc, double>(
      (bloc) => bloc.state.netWorth,
    );
    final defaultCurrency = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.model.defaultCurrency,
    );

    final currency = NumberFormat.currency(name: defaultCurrency).currencyName;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.netWorth,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$currency $netWorth',
            style: AppTextStyles.heading1.copyWith(fontSize: 34),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
