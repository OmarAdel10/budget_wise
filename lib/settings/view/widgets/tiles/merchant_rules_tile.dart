import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class MerchantRulesTile extends StatelessWidget {
  const MerchantRulesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnabled = context.select(
      (SettingsBloc bloc) => bloc.state.model.merchantRulesEnabled,
    );

    return SettingsTile(
      icon: PhosphorIconsRegular.storefront,
      title: context.l10n.merchantRulesEnabled,
      subtitle: context.l10n.merchantRulesEnabledInfo,
      hasPadding: true,
      trailing: Transform.scale(
        scale: 0.7,
        child: Switch(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: isEnabled,
          onChanged: (_) {
            context.read<SettingsBloc>().add(
              const SettingsEventToggleMerchantRules(),
            );
          },
          activeThumbColor: AppColors.primaryAccent,
          activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
