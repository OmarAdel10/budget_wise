import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SecuritySettingsTile extends StatelessWidget {
  const SecuritySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLocalAuthEnabled = context.select(
      (SettingsBloc bloc) => bloc.state.model.localAuthEnabled,
    );

    return SettingsTile(
      icon: PhosphorIconsRegular.fingerprint,
      title: l10n.security,
      subtitle: l10n.bioMetrics,
      showDivider: true,
      trailing: Switch(
        value: isLocalAuthEnabled,
        onChanged: (value) {
          context.read<SettingsBloc>().add(const SettingsEventLocalAuth());
        },
        activeThumbColor: AppColors.primaryAccent,
        activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.3),
      ),
    );
  }
}
