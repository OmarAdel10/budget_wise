import 'package:budget_wise/currency_conversions/view/currency_conversion_preview.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/buckets/view/widgets/savings_color_picker.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/accounts/view/widgets/account_field.dart';
import 'package:budget_wise/shared/widgets/alert_setting_card.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/widgets/drag_handle.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/icon_picker_bottom_sheet.dart';
import 'package:budget_wise/shared/widgets/date_picker_field.dart';
import 'package:budget_wise/shared/widgets/category_dropdown.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_icon_picker.dart';
import 'package:budget_wise/subscriptions/view/widgets/billing_cycle_selector.dart';
import 'package:budget_wise/subscriptions/view/widgets/next_billing_preview.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_basic_info_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSubscriptionBottomSheet extends StatefulWidget {
  static const String routeName = '/add-subscription';
  final SubscriptionModel? subscriptionToEdit;

  const AddSubscriptionBottomSheet({super.key, this.subscriptionToEdit});

  @override
  State<AddSubscriptionBottomSheet> createState() =>
      _AddSubscriptionBottomSheetState();
}

class _AddSubscriptionBottomSheetState
    extends State<AddSubscriptionBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final TextEditingController reminderController = TextEditingController();

  late final ValueNotifier<DateTime> _startDateNotifier;
  late final ValueNotifier<BillingCycle> _billingCycleNotifier;
  late final ValueNotifier<String?> _selectedCategoryIdNotifier;
  late final ValueNotifier<String?> _selectedAccountIdNotifier;
  late final ValueNotifier<IconData> _selectedIconNotifier;
  late final ValueNotifier<Color> _selectedColorNotifier;
  late final ValueNotifier<String> _selectedCurrency;
  late final ValueNotifier<bool> reminderEnabledNotifier;
  late final ValueNotifier<bool> inActiveStatusNotifier;

  bool get _isEditMode => widget.subscriptionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final sub = widget.subscriptionToEdit!;
      _nameController.text = sub.name;
      _amountController.text = sub.amount.toStringAsFixed(2);
      _startDateNotifier = ValueNotifier(sub.startDate);
      _billingCycleNotifier = ValueNotifier(sub.billingCycle);
      _selectedCategoryIdNotifier = ValueNotifier(sub.categoryId);
      _selectedAccountIdNotifier = ValueNotifier(sub.accountId);
      _selectedIconNotifier = ValueNotifier(sub.icon);
      _selectedColorNotifier = ValueNotifier(Color(sub.iconColorValue));
      _selectedCurrency = ValueNotifier(sub.currency);
      reminderEnabledNotifier = ValueNotifier(sub.reminderEnabled);
      reminderController.text = sub.remindBeforeDays.toString();
      inActiveStatusNotifier = ValueNotifier(!sub.inActive);
    } else {
      _startDateNotifier = ValueNotifier(DateTime.now());
      _billingCycleNotifier = ValueNotifier(BillingCycle.monthly);
      _selectedCategoryIdNotifier = ValueNotifier(null);
      _selectedAccountIdNotifier = ValueNotifier(null);
      _selectedIconNotifier = ValueNotifier(PhosphorIconsFill.repeat);
      _selectedColorNotifier = ValueNotifier(
        Color(SavingGoalColorPicker.colorOptions.first),
      );
      _selectedCurrency = ValueNotifier(
        context.read<SettingsBloc>().state.currencySymbol,
      );
      reminderEnabledNotifier = ValueNotifier(true);
      reminderController.text = '1';
      inActiveStatusNotifier = ValueNotifier(false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _startDateNotifier.dispose();
    _billingCycleNotifier.dispose();
    _selectedCategoryIdNotifier.dispose();
    _selectedAccountIdNotifier.dispose();
    _selectedIconNotifier.dispose();
    _selectedColorNotifier.dispose();
    _selectedCurrency.dispose();
    reminderEnabledNotifier.dispose();
    reminderController.dispose();
    inActiveStatusNotifier.dispose();
    super.dispose();
  }

  Future<void> schecduleNotifcationInitialization({
    required SubscriptionModel subscription,
  }) async {
    final int baseId = subscription.createdAt.millisecondsSinceEpoch ~/ 1000;
    for (int i = 0; i <= 31; i++) {
      await NotificationRepository.cancelNotificationById(baseId + i);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool allEnabled = prefs.getBool('all_notifications_enabled') ?? true;
    final bool subEnabled =
        prefs.getBool('subscription_notifications_enabled') ?? true;

    if (!allEnabled || !subEnabled) {
      return; // Do not schedule if notifications are disabled
    }

    if (subscription.reminderEnabled) {
      for (int i = 0; i <= subscription.remindBeforeDays; i++) {
        final date = subscription.nextBillingDate.subtract(Duration(days: i));
        if (date.isBefore(DateTime.now())) continue;
        await NotificationRepository.scheduledNotification(
          channelId: 'subscription_transactions',
          channelName: 'Subscription Reminder',
          channelDescription: 'Notifications for Subscriptions Due Date',
          id: baseId + i,
          title: '${subscription.name} Reminder',
          body: i == 0
              ? 'Your payment for ${subscription.name} is due today!'
              : 'You still have $i day(s) left to pay ${subscription.amount}${subscription.currency} for ${subscription.name}',
          payload: 'subscription_${subscription.id}',
          scheduledDate: date,
        );
      }
    } else {
      if (subscription.nextBillingDate.isAfter(DateTime.now())) {
        await NotificationRepository.scheduledNotification(
          channelId: 'subscription_transactions',
          channelName: 'Subscription Reminder',
          channelDescription: 'Notifications for Subscriptions Due Date',
          id: baseId,
          title: '${subscription.name} Reminder',
          body: 'Your payment for ${subscription.name} is due today!',
          payload: 'subscription_${subscription.id}',
          scheduledDate: subscription.nextBillingDate,
        );
      }
    }
  }

  void _onUpdateSubscription({
    required String name,
    required double amount,
    required BillingCycle cycle,
    required DateTime startDate,
    required DateTime nextBilling,
    required int reminderBeforeDaysCount,
  }) async {
    final updatedSub = widget.subscriptionToEdit!.copyWith(
      name: name,
      amount: amount,
      currency: _selectedCurrency.value,
      categoryId: _selectedCategoryIdNotifier.value,
      accountId: _selectedAccountIdNotifier.value,
      icon: _selectedIconNotifier.value,
      iconColorValue: _selectedColorNotifier.value.toARGB32(),
      billingCycle: cycle,
      startDate: startDate,
      billingDay: startDate.day,
      nextBillingDate: nextBilling,
      reminderEnabled: reminderEnabledNotifier.value,
      remindBeforeDays: reminderBeforeDaysCount,
      inActive: !inActiveStatusNotifier.value,
      updatedAt: DateTime.now(),
    );
    context.read<SubscriptionBloc>().add(SubscriptionUpdated(updatedSub));
    if (!updatedSub.inActive) {
      await schecduleNotifcationInitialization(subscription: updatedSub);
    }
  }

  void _onSaveNewSubscription({
    required String name,
    required double amount,
    required BillingCycle cycle,
    required DateTime startDate,
    required DateTime nextBilling,
    required int reminderBeforeDaysCount,
  }) async {
    final newSub = SubscriptionModel(
      name: name,
      amount: amount,
      currency: _selectedCurrency.value,
      billingCycle: cycle,
      categoryId: _selectedCategoryIdNotifier.value!,
      accountId: _selectedAccountIdNotifier.value!,
      icon: _selectedIconNotifier.value,
      iconColorValue: _selectedColorNotifier.value.toARGB32(),
      startDate: startDate,
      billingDay: startDate.day,
      nextBillingDate: nextBilling,
      reminderEnabled: reminderEnabledNotifier.value,
      remindBeforeDays: reminderBeforeDaysCount,
      inActive: !inActiveStatusNotifier.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<SubscriptionBloc>().add(SubscriptionAdded(newSub));
    if (!newSub.inActive) {
      await schecduleNotifcationInitialization(subscription: newSub);
    }
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);
    final reminderBeforeDaysCount = int.tryParse(reminderController.text) ?? 1;
    final startDate = _startDateNotifier.value;
    final billingCycle = _billingCycleNotifier.value;
    final nextBilling = BillingUtils.calculateNextBillingDate(
      lastBillingDate: startDate,
      billingDay: startDate.day,
      cycle: billingCycle,
    );

    if (name.isEmpty ||
        amount == null ||
        _selectedCategoryIdNotifier.value == null ||
        _selectedAccountIdNotifier.value == null) {
      AppToast.show(
        context,
        title: context.l10n.pleaseFillRequiredFields,
        type: AppToastType.error,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        _onUpdateSubscription(
          name: name,
          amount: amount,
          cycle: billingCycle,
          startDate: startDate,
          nextBilling: nextBilling,
          reminderBeforeDaysCount: reminderBeforeDaysCount,
        );
      } else {
        _onSaveNewSubscription(
          name: name,
          amount: amount,
          cycle: billingCycle,
          startDate: startDate,
          nextBilling: nextBilling,
          reminderBeforeDaysCount: reminderBeforeDaysCount,
        );
      }

      Navigator.pop(context);

      AppToast.show(
        context,
        title: _isEditMode
            ? context.l10n.subscriptionUpdatedSuccessfully
            : context.l10n.subscriptionCreatedSuccessfully,
        type: AppToastType.success,
      );
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.5,
        child: IconPickerBottomSheet.hasColorPalete(
          onIconSelected: (icon) => _selectedIconNotifier.value = icon,
          selectedColorNotifier: _selectedColorNotifier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const DragHandle(),
                  Text(
                    _isEditMode
                        ? context.l10n.editSubscription
                        : context.l10n.addSubscription,
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RepaintBoundary(
                    child: SubscriptionIconPicker(
                      iconNotifier: _selectedIconNotifier,
                      colorNotifier: _selectedColorNotifier,
                      onTap: _showIconPicker,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  RepaintBoundary(
                    child: Form(
                      key: _formKey,
                      child: SubscriptionBasicInfoFields(
                        nameController: _nameController,
                        amountController: _amountController,
                        selectedCurrency: _selectedCurrency,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: CategoryDropdown(
                      selectedCategoryId: _selectedCategoryIdNotifier,
                      fixedType: TransactionType.expense,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // RepaintBoundary(
                  //   child: AccountField(
                  //     // iconBackgroundColor: AppColors.primaryAccent,
                  //     selectedAccountIdNotifier: _selectedAccountIdNotifier,
                  //   ),
                  // ),
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedAccountIdNotifier,
                    builder: (context, accountId, _) {
                      return ValueListenableBuilder<String>(
                        valueListenable: _selectedCurrency,
                        builder: (context, currency, _) {
                          if (accountId == null) {
                            return const SizedBox.shrink();
                          }

                          final account = context
                              .read<AccountBloc>()
                              .state
                              .accountsList
                              .firstWhere((a) => a.id == accountId);

                          if (account.currency == currency) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.lg),
                            child: ListenableBuilder(
                              listenable: _amountController,
                              builder: (context, _) {
                                final amount =
                                    double.tryParse(
                                      _amountController.text.replaceAll(
                                        ',',
                                        '',
                                      ),
                                    ) ??
                                    0.0;
                                return CurrencyConversionPreview(
                                  amount: amount,
                                  fromCurrency: currency,
                                  toCurrency: account.currency,
                                  onConvertedAmountChanged: (val) {},
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.billingCycle,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        BillingCycleSelector(
                          billingCycleNotifier: _billingCycleNotifier,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: DatePickerField(
                      selectedDate: _startDateNotifier,
                      activeColor: AppColors.primaryAccent,
                      label: context.l10n.startDate,
                      lastDate: DateTime(2100),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: NextBillingPreview(
                      startDateNotifier: _startDateNotifier,
                      billingCycleNotifier: _billingCycleNotifier,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: inActiveStatusNotifier,
                      builder: (context, inActiveStatus, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                          ),
                          child: SwitchListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              side: BorderSide(
                                color: AppColors.borderColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            tileColor: AppColors.inputBackground,
                            value: inActiveStatus,
                            onChanged: (value) {
                              inActiveStatusNotifier.value = value;
                            },
                            title: Text(context.l10n.activeStatus),
                            subtitle: Text(
                              '${context.l10n.trackingStatus} ${inActiveStatus ? context.l10n.active : context.l10n.paused}',
                              style: AppTextStyles.bodySmall,
                            ),
                            secondary: Icon(
                              PhosphorIconsBold.bellRinging,
                              color: inActiveStatus
                                  ? AppColors.primaryAccent
                                  : AppColors.textSecondary,
                            ),
                            activeThumbColor: AppColors.primaryAccent,
                            activeTrackColor: AppColors.primaryAccent
                                .withValues(alpha: 0.3),
                            inactiveTrackColor: AppColors.inputBackground,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RepaintBoundary(
                    child: AlertSettingCard(
                      enabledNotifier: reminderEnabledNotifier,
                      alertAmountController: reminderController,
                      backgroundColorDecoration: AppColors.inputBackground,
                      textFieldBgColor: AppColors.cardBackground,
                      settingTitle: context.l10n.reminder,
                      textFieldTitle: context.l10n.reminderBeforeDays,
                      note: context.l10n.reminderInfo,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  RepaintBoundary(
                    child: CustomButton(
                      text: _isEditMode
                          ? context.l10n.saveChanges
                          : context.l10n.addSubscription,
                      onPressed: _onSave,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
