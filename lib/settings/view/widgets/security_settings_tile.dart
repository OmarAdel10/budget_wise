import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/screens/passcode_setup_screen.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SecuritySettingsTile extends StatelessWidget {
  const SecuritySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    final model = settingsState.model;
    final isLocalAuthEnabled = model.localAuthEnabled;
    final isPasscodeSet = model.isPasscodeSet;

    return Column(
      children: [
        SettingsTile(
          icon: PhosphorIconsRegular.fingerprint,
          title: l10n.security,
          subtitle: l10n.bioMetrics,
          showDivider: isLocalAuthEnabled,
          trailing: Switch(
            value: isLocalAuthEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(const SettingsEventLocalAuth());
            },
            activeThumbColor: AppColors.primaryAccent,
            activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.3),
          ),
        ),
        if (isLocalAuthEnabled)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                SettingsTile(
                  icon: PhosphorIconsRegular.key,
                  title: isPasscodeSet ? l10n.changePasscode : l10n.setPasscode,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      PasscodeSetupScreen.routeName,
                    );
                  },
                  showDivider: isPasscodeSet,
                ),
                if (isPasscodeSet)
                  SettingsTile(
                    icon: PhosphorIconsRegular.scan,
                    title: l10n.useBiometrics,
                    showDivider: false,
                    trailing: Switch(
                      value: model.useBiometrics,
                      onChanged: (value) =>
                        context
                            .read<SettingsBloc>()
                            .add(const SettingsEventToggleBiometrics()),
                      activeThumbColor: AppColors.primaryAccent,
                      activeTrackColor: AppColors.primaryAccent.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
