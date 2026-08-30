import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/tiles/recent_transactions_count_picker_bottom_sheet.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class RecentTransactionsCountTile extends StatelessWidget {
  const RecentTransactionsCountTile({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCount = context.select(
      (SettingsBloc bloc) => bloc.state.model.recentTransactionDisplayedCount,
    );

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RecentTransactionsCountPickerBottomSheet(
          selectedCount: currentCount,
          onCountSelected: (count) {
            context.read<SettingsBloc>().add(
              SettingsEventChangeRecentTransactionCount(count),
            );
          },
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsRegular.listNumbers,
        title: context.l10n.recentTransactionsCount,
        subtitle: context.l10n.recentTransactionsCountInfo,
        hasPadding: true,
        paddingVertical: AppSpacing.md,
        showDivider: true,
        trailing: Row(
          children: [
            Text(currentCount.toString(), style: AppTextStyles.bodyMedium),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
