import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/shared/widgets/icon_picker_bottom_sheet.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:toastification/toastification.dart';

class AddSubscriptionScreen extends StatefulWidget {
  static const String routeName = '/add-subscription';
  final SubscriptionModel? subscriptionToEdit;

  const AddSubscriptionScreen({super.key, this.subscriptionToEdit});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _startDate;
  late BillingCycle _billingCycle;
  String? _selectedCategoryId;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late bool _reminderEnabled;
  late int _remindBeforeDays;

  bool get _isEditMode => widget.subscriptionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final sub = widget.subscriptionToEdit!;
      _nameController.text = sub.name;
      _amountController.text = sub.amount.toStringAsFixed(2);
      _startDate = sub.startDate;
      _billingCycle = sub.billingCycle;
      _selectedCategoryId = sub.categoryId;
      _selectedIcon = sub.icon;
      _reminderEnabled = sub.reminderEnabled;
      _remindBeforeDays = sub.remindBeforeDays;
    } else {
      _startDate = DateTime.now();
      _billingCycle = BillingCycle.monthly;
      _selectedIcon = PhosphorIcons.repeat(PhosphorIconsStyle.fill);
      _selectedColor = AppColors.primaryAccent;
      _reminderEnabled = true;
      _remindBeforeDays = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);
    // final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty || amount == null || _selectedCategoryId == null) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: const Text('Please fill all required fields'),
      );
      return;
    }

    final nextBilling = BillingUtils.calculateNextBillingDate(
      lastBillingDate: _startDate,
      billingDay: _startDate.day,
      cycle: _billingCycle,
    );

    final sub = SubscriptionModel(
      id: _isEditMode ? widget.subscriptionToEdit!.id : '',
      name: name,
      amount: amount,
      currency: 'EGP', // Hardcoded for now per project standard
      billingCycle: _billingCycle,
      categoryId: _selectedCategoryId!,
      icon: _selectedIcon,
      startDate: _startDate,
      billingDay: _startDate.day,
      nextBillingDate: nextBilling,
      reminderEnabled: _reminderEnabled,
      remindBeforeDays: _remindBeforeDays,
      createdAt: _isEditMode
          ? widget.subscriptionToEdit!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditMode) {
      context.read<SubscriptionBloc>().add(SubscriptionUpdated(sub));
    } else {
      context.read<SubscriptionBloc>().add(SubscriptionAdded(sub));
    }

    Navigator.pop(context);
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.5,
        child: IconPickerBottomSheet(
          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nextBillingPreview = BillingUtils.calculateNextBillingDate(
      lastBillingDate: _startDate,
      billingDay: _startDate.day,
      cycle: _billingCycle,
    );

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text(_isEditMode ? l10n.editSubscription : l10n.addSubscription),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Color Picker
            Center(
              child: GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _selectedColor),
                  ),
                  child: Icon(_selectedIcon, size: 40, color: _selectedColor),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            CustomTextField(
              hintText: 'Subscription Name (e.g. Netflix)',
              controller: _nameController,
            ),
            const SizedBox(height: AppSpacing.lg),

            CustomTextField(
              hintText: l10n.amount,
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Category Picker
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                final categories = state.categoriesList
                    .where((c) => c.type == TransactionType.expense)
                    .toList();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategoryId,
                      hint: Text(
                        l10n.category,
                        style: AppTextStyles.bodyMedium,
                      ),
                      isExpanded: true,
                      dropdownColor: AppColors.cardBackground,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.categoryTitle,
                                style: AppTextStyles.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Billing Cycle Selector
            Text(l10n.billingCycle, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            _buildBillingCycleSelector(l10n),
            const SizedBox(height: AppSpacing.lg),

            // Start Date Picker
            Text('Start Date', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _startDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMd().format(_startDate),
                      style: AppTextStyles.bodyLarge,
                    ),
                    Icon(
                      PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Next Billing Preview
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.nextRenewalDate, style: AppTextStyles.bodySmall),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(nextBillingPreview),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            CustomButton(
              text: _isEditMode ? l10n.saveChanges : l10n.addSubscription,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCycleSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 4,
        children: BillingCycle.values.map((cycle) {
          return _buildToggleButton(
            label: _getCycleLabel(cycle, l10n),
            isSelected: _billingCycle == cycle,
            onTap: () => setState(() => _billingCycle = cycle),
          );
        }).toList(),
      ),
    );
  }

  String _getCycleLabel(BillingCycle cycle, AppLocalizations l10n) {
    switch (cycle) {
      case BillingCycle.weekly:
        return l10n.weekly;
      case BillingCycle.monthly:
        return l10n.monthly;
      case BillingCycle.quarterly:
        return l10n.quarterly;
      case BillingCycle.halfYearly:
        return l10n.halfYearly;
      case BillingCycle.yearly:
        return l10n.yearly;
    }
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  isSelected ? AppColors.textInverse : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
