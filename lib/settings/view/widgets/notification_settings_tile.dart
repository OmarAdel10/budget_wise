import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NotificationSettingsTile extends StatelessWidget {
  const NotificationSettingsTile({super.key});

  void _showDisableWarningDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onContinue,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(title, style: AppTextStyles.heading3),
        content: Text(content, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: Text(
              l10n.continueAction,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Permission Required'),
        content: const Text(
          'Notification permissions are disabled in system settings. Please enable them to receive alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Note: Opening settings usually requires a package like app_settings
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    bool currentValue,
    SettingsEvent toggleEvent,
    String warningTitle,
    String warningContent,
  ) async {
    if (currentValue) {
      // Trying to disable -> Show warning
      _showDisableWarningDialog(
        context,
        warningTitle,
        warningContent,
        () => context.read<SettingsBloc>().add(toggleEvent),
      );
    } else {
      // Trying to enable -> Check OS permissions first
      final granted = await NotificationRepository.isPermissionGranted();
      if (!granted) {
        if (context.mounted) {
          _showPermissionDialog(context);
        }
        return;
      }
      if (context.mounted) {
        context.read<SettingsBloc>().add(toggleEvent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final model = state.model;
        final allEnabled = model.allNotificationsEnabled;
        final bool allNotificationsEnabled =
            model.allNotificationsEnabled &&
            model.dailyReminderNotificationsEnabled &&
            model.smsNotificationsEnabled &&
            model.categoryBudgetNotificationsEnabled &&
            model.subscriptionNotificationsEnabled &&
            model.savingsNotificationsEnabled;

        // Build dynamic summary
        List<String> activeServices = [];
        if (model.smsNotificationsEnabled) activeServices.add(l10n.sms);
        if (model.subscriptionNotificationsEnabled) {
          activeServices.add(l10n.subscriptions);
        }
        if (model.savingsNotificationsEnabled) {
          activeServices.add(l10n.navSavings);
        }
        if (model.dailyReminderNotificationsEnabled) {
          activeServices.add(l10n.daily);
        }
        if (model.categoryBudgetNotificationsEnabled) {
          activeServices.add(l10n.categoryBudget);
        }

        String subtitle = allEnabled
            ? (activeServices.isEmpty
                  ? l10n.noServicesActive
                  : allNotificationsEnabled
                  ? l10n.allAlertsActive
                  : l10n.activeServicesLabel(activeServices.join(", ")))
            : l10n.allAlertsSilenced;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTile(
              icon: PhosphorIconsRegular.bellRinging,
              title: l10n.allNotifications,
              subtitle: subtitle,
              showDivider: true,
              trailing: CupertinoSwitch(
                value: allEnabled,
                activeTrackColor: AppColors.primaryAccent,
                onChanged: (_) => _handleToggle(
                  context,
                  allEnabled,
                  const SettingsEventToggleAllNotifications(),
                  l10n.disableNotificationsWarningTitle,
                  l10n.disableAllNotificationsWarningDesc,
                ),
              ),
            ),
            IgnorePointer(
              ignoring: !allEnabled,
              child: Opacity(
                opacity: allEnabled ? 1.0 : 0.5,
                child: Column(
                  children: [
                    // Daily Reminder
                    SettingsTile(
                      icon: PhosphorIconsRegular.clock,
                      title: l10n.dailyReminderNotifications,
                      showDivider: true,
                      trailing: CupertinoSwitch(
                        value: model.dailyReminderNotificationsEnabled,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: (_) => _handleToggle(
                          context,
                          model.dailyReminderNotificationsEnabled,
                          const SettingsEventToggleDailyReminderNotifications(),
                          l10n.disableNotificationsWarningTitle,
                          l10n.disableDailyReminderNotificationsWarningDesc,
                        ),
                      ),
                    ),
                    // Sms Draft
                    SettingsTile(
                      icon: PhosphorIconsRegular.chatCircleText,
                      title: l10n.smsDraftNotifications,
                      showDivider: true,
                      trailing: CupertinoSwitch(
                        value: model.smsNotificationsEnabled,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: (_) => _handleToggle(
                          context,
                          model.smsNotificationsEnabled,
                          const SettingsEventToggleSmsNotifications(),
                          l10n.disableNotificationsWarningTitle,
                          l10n.disableSmsNotificationsWarningDesc,
                        ),
                      ),
                    ),
                    // Catgory Budget
                    SettingsTile(
                      icon: PhosphorIconsRegular.trendUp,
                      title: l10n.categoryBudgetNotifications,
                      showDivider: true,
                      trailing: CupertinoSwitch(
                        value: model.categoryBudgetNotificationsEnabled,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: (_) => _handleToggle(
                          context,
                          model.categoryBudgetNotificationsEnabled,
                          const SettingsEventToggleCategoryBudgetNotifications(),
                          l10n.disableNotificationsWarningTitle,
                          l10n.disableCategoryBudgetNotificationsWarningDesc,
                        ),
                      ),
                    ),
                    // Subscriptions
                    SettingsTile(
                      icon: PhosphorIconsRegular.calendar,
                      title: l10n.subscriptionNotifications,
                      showDivider: true,
                      trailing: CupertinoSwitch(
                        value: model.subscriptionNotificationsEnabled,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: (_) => _handleToggle(
                          context,
                          model.subscriptionNotificationsEnabled,
                          const SettingsEventToggleSubscriptionNotifications(),
                          l10n.disableNotificationsWarningTitle,
                          l10n.disableSubNotificationsWarningDesc,
                        ),
                      ),
                    ),
                    // Savings
                    SettingsTile(
                      icon: PhosphorIconsRegular.piggyBank,
                      title: l10n.savingsNotifications,
                      showDivider: false,
                      trailing: CupertinoSwitch(
                        value: model.savingsNotificationsEnabled,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: (_) => _handleToggle(
                          context,
                          model.savingsNotificationsEnabled,
                          const SettingsEventToggleSavingsNotifications(),
                          l10n.disableNotificationsWarningTitle,
                          l10n.disableSavingsNotificationsWarningDesc,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
