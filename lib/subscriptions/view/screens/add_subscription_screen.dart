import 'package:budget_wise/savings/view/widgets/savings_color_picker.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/widgets/alert_setting_card.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
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
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddSubscriptionScreen extends StatefulWidget {
  static const String routeName = '/add-subscription';
  final SubscriptionModel? subscriptionToEdit;

  const AddSubscriptionScreen({super.key, this.subscriptionToEdit});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final TextEditingController reminderController = TextEditingController();

  late final ValueNotifier<DateTime> _startDateNotifier;
  late final ValueNotifier<BillingCycle> _billingCycleNotifier;
  late final ValueNotifier<String?> _selectedCategoryIdNotifier;
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
      _selectedIconNotifier = ValueNotifier(
        PhosphorIcons.repeat(PhosphorIconsStyle.fill),
      );
      _selectedColorNotifier = ValueNotifier(
        Color(SavingsColorPicker.colorOptions.first),
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
    _selectedIconNotifier.dispose();
    _selectedColorNotifier.dispose();
    _selectedCurrency.dispose();
    reminderEnabledNotifier.dispose();
    reminderController.dispose();
    inActiveStatusNotifier.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);
    final l10n = AppLocalizations.of(context)!;
    final remindBeforeDays = int.tryParse(reminderController.text) ?? 1;
    final startDate = _startDateNotifier.value;
    final billingCycle = _billingCycleNotifier.value;
    final nextBilling = BillingUtils.calculateNextBillingDate(
      lastBillingDate: startDate,
      billingDay: startDate.day,
      cycle: billingCycle,
    );

    if (name.isEmpty ||
        amount == null ||
        _selectedCategoryIdNotifier.value == null) {
      AppToast.show(
        context,
        title: l10n.pleaseFillRequiredFields,
        type: AppToastType.error,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        final updatedSub = widget.subscriptionToEdit!.copyWith(
          name: name,
          amount: amount,
          currency: _selectedCurrency.value,
          categoryId: _selectedCategoryIdNotifier.value,
          icon: _selectedIconNotifier.value,
          iconColorValue: _selectedColorNotifier.value.toARGB32(),
          billingCycle: billingCycle,
          startDate: startDate,
          billingDay: startDate.day,
          nextBillingDate: nextBilling,
          reminderEnabled: reminderEnabledNotifier.value,
          remindBeforeDays: remindBeforeDays,
          inActive: !inActiveStatusNotifier.value,
          updatedAt: DateTime.now(),
        );
        context.read<SubscriptionBloc>().add(SubscriptionUpdated(updatedSub));
      } else {
        final newSub = SubscriptionModel(
          name: name,
          amount: amount,
          currency: _selectedCurrency.value,
          billingCycle: billingCycle,
          categoryId: _selectedCategoryIdNotifier.value!,
          icon: _selectedIconNotifier.value,
          iconColorValue: _selectedColorNotifier.value.toARGB32(),
          startDate: startDate,
          billingDay: startDate.day,
          nextBillingDate: nextBilling,
          inActive: !inActiveStatusNotifier.value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        context.read<SubscriptionBloc>().add(SubscriptionAdded(newSub));
      }

      Navigator.pop(context);
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(_isEditMode ? l10n.editSubscription : l10n.addSubscription),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          cacheExtent: 1000,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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

                  RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.billingCycle,
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
                      label: l10n.startDate,
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
                            title: Text(l10n.activeStatus),
                            subtitle: Text(
                              '${l10n.trackingStatus} ${inActiveStatus ? l10n.active : l10n.paused}',
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
                      settingTitle: l10n.reminder,
                      textFieldTitle: l10n.reminderBeforeDays,
                      note: l10n.reminderInfo,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  RepaintBoundary(
                    child: CustomButton(
                      text: _isEditMode
                          ? l10n.saveChanges
                          : l10n.addSubscription,
                      onPressed: _onSave,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
