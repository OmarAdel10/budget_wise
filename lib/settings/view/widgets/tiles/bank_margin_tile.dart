import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/numeric_editor_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BankMarginTile extends StatelessWidget {
  const BankMarginTile({super.key});

  void _showEditBottomSheet(BuildContext context) {
    final margin = context.read<SettingsBloc>().state.model.bankMargin;

    NumericEditorBottomSheet.show(
      context,
      title: context.l10n.bankMargin,
      description: context.l10n.bankMarginInfo,
      initialValue: margin,
      suffixText: '%',
      onSave: (value) {
        context.read<SettingsBloc>().add(SettingsEventBankMarginChanged(value));
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return SettingsTile(
      icon: PhosphorIconsRegular.percent,
      title: context.l10n.bankMargin,
      subtitle: context.l10n.bankMarginInfo,
      showDivider: true,
      onTap: () => _showEditBottomSheet(context),
      trailing: const _BankMarginTrailing(),
    );
  }
}

class _BankMarginTrailing extends StatelessWidget {
  const _BankMarginTrailing();

  Color _getMarginColor(double margin) {
    if (margin <= 2.0) return AppColors.textSecondary;
    if (margin <= 5.0) return Colors.orangeAccent;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final margin = context.select(
      (SettingsBloc bloc) => bloc.state.model.bankMargin,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.bankMarginValue(margin),
          style: AppTextStyles.bodyMedium.copyWith(
            color: _getMarginColor(margin),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(
          PhosphorIconsRegular.caretRight,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ],
    );
  }
}
