import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class NotificationSettingsTile extends StatelessWidget {
  const NotificationSettingsTile({super.key});

  void _showDisableWarningDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(title, style: AppTextStyles.heading3),
        content: Text(content, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel, style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: Text(
              context.l10n.continueAction,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(context.l10n.permissionRequired),
        content: Text(
          context
              .l10n
              .disableNotificationsWarningTitle, // Reusing similar warning or add new one
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Note: Opening settings usually requires a package like app_settings
              Navigator.pop(context);
            },
            child: Text(context.l10n.openSettings),
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
        if (model.smsNotificationsEnabled) activeServices.add(context.l10n.sms);
        if (model.subscriptionNotificationsEnabled) {
          activeServices.add(context.l10n.subscriptions);
        }
        if (model.savingsNotificationsEnabled) {
          activeServices.add(context.l10n.navSavings);
        }
        if (model.dailyReminderNotificationsEnabled) {
          activeServices.add(context.l10n.daily);
        }
        if (model.categoryBudgetNotificationsEnabled) {
          activeServices.add(context.l10n.categoryBudget);
        }

        String subtitle = allEnabled
            ? (activeServices.isEmpty
                  ? context.l10n.noServicesActive
                  : allNotificationsEnabled
                  ? context.l10n.allAlertsActive
                  : context.l10n.activeServicesLabel(activeServices.join(", ")))
            : context.l10n.allAlertsSilenced;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTile(
              icon: PhosphorIconsRegular.bellRinging,
              title: context.l10n.allNotifications,
              subtitle: subtitle,
              showDivider: true,
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: allEnabled,
                  activeThumbColor: AppColors.primaryAccent,
                  activeTrackColor: AppColors.primaryAccent.withValues(
                    alpha: 0.3,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => _handleToggle(
                    context,
                    allEnabled,
                    const SettingsEventToggleAllNotifications(),
                    context.l10n.disableNotificationsWarningTitle,
                    context.l10n.disableAllNotificationsWarningDesc,
                  ),
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
                      title: context.l10n.dailyReminderNotifications,
                      showDivider: true,
                      trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: model.dailyReminderNotificationsEnabled,
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => _handleToggle(
                            context,
                            model.dailyReminderNotificationsEnabled,
                            const SettingsEventToggleDailyReminderNotifications(),
                            context.l10n.disableNotificationsWarningTitle,
                            context
                                .l10n
                                .disableDailyReminderNotificationsWarningDesc,
                          ),
                        ),
                      ),
                    ),
                    // Sms Draft
                    SettingsTile(
                      icon: PhosphorIconsRegular.chatCircleText,
                      title: context.l10n.smsDraftNotifications,
                      showDivider: true,
                      trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: model.smsNotificationsEnabled,
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => _handleToggle(
                            context,
                            model.smsNotificationsEnabled,
                            const SettingsEventToggleSmsNotifications(),
                            context.l10n.disableNotificationsWarningTitle,
                            context.l10n.disableSmsNotificationsWarningDesc,
                          ),
                        ),
                      ),
                    ),
                    // Catgory Budget
                    SettingsTile(
                      icon: PhosphorIconsRegular.trendUp,
                      title: context.l10n.categoryBudgetNotifications,
                      showDivider: true,
                      trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: model.categoryBudgetNotificationsEnabled,
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => _handleToggle(
                            context,
                            model.categoryBudgetNotificationsEnabled,
                            const SettingsEventToggleCategoryBudgetNotifications(),
                            context.l10n.disableNotificationsWarningTitle,
                            context
                                .l10n
                                .disableCategoryBudgetNotificationsWarningDesc,
                          ),
                        ),
                      ),
                    ),
                    // Subscriptions
                    SettingsTile(
                      icon: PhosphorIconsRegular.calendar,
                      title: context.l10n.subscriptionNotifications,
                      showDivider: true,
                      trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: model.subscriptionNotificationsEnabled,
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => _handleToggle(
                            context,
                            model.subscriptionNotificationsEnabled,
                            const SettingsEventToggleSubscriptionNotifications(),
                            context.l10n.disableNotificationsWarningTitle,
                            context.l10n.disableSubNotificationsWarningDesc,
                          ),
                        ),
                      ),
                    ),
                    // Savings
                    SettingsTile(
                      icon: PhosphorIconsRegular.piggyBank,
                      title: context.l10n.savingsNotifications,
                      showDivider: false,
                      trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: model.savingsNotificationsEnabled,
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) => _handleToggle(
                            context,
                            model.savingsNotificationsEnabled,
                            const SettingsEventToggleSavingsNotifications(),
                            context.l10n.disableNotificationsWarningTitle,
                            context.l10n.disableSavingsNotificationsWarningDesc,
                          ),
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
