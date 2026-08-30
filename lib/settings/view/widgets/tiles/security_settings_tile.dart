import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/screens/passcode_setup_screen.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SecuritySettingsTile extends StatelessWidget {
  const SecuritySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    final model = settingsState.model;
    final isLocalAuthEnabled = model.localAuthEnabled;
    final isPasscodeSet = model.isPasscodeSet;

    return Column(
      children: [
        SettingsTile(
          icon: PhosphorIconsRegular.lock,
          title: context.l10n.appLock,
          trailing: Transform.scale(
            scale: 0.7,
            child: Switch(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: isLocalAuthEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  const SettingsEventLocalAuth(),
                );
              },
              activeThumbColor: AppColors.primaryAccent,
              activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.3),
            ),
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
                  title: isPasscodeSet
                      ? context.l10n.changePasscode
                      : context.l10n.setPasscode,
                  hasPadding: true,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(PasscodeSetupScreen.routeName);
                  },
                  showDivider: isPasscodeSet,
                ),
                if (isPasscodeSet)
                  SettingsTile(
                    icon: PhosphorIconsRegular.fingerprint,
                    title: context.l10n.useBiometrics,
                    // showDivider: true,
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: model.useBiometrics,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) => context.read<SettingsBloc>().add(
                          const SettingsEventToggleBiometrics(),
                        ),
                        activeThumbColor: AppColors.primaryAccent,
                        activeTrackColor: AppColors.primaryAccent.withValues(
                          alpha: 0.3,
                        ),
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
