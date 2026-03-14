import 'dart:math';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

import '../widgets/savings_mode_toggle.dart';
import '../widgets/goal_name_input.dart';
import '../widgets/target_amount_input.dart';
import '../widgets/target_days_input.dart';
import '../widgets/calculation_method_grid.dart';
import '../widgets/target_date_display.dart';
import '../widgets/savings_color_picker.dart';
import '../widgets/savings_info_section.dart';

class AddSavingGoalScreen extends StatefulWidget {
  static const String routeName = '/add-saving-goal';

  const AddSavingGoalScreen({super.key});

  @override
  State<AddSavingGoalScreen> createState() => _AddSavingGoalScreenState();
}

class _AddSavingGoalScreenState extends State<AddSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _constantController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _daysFocusNode = FocusNode();

  late final ValueNotifier<DateTime> _targetDateNotifier;
  late final ValueNotifier<bool> _isByAmountNotifier;
  late final ValueNotifier<SavingsMethod> _selectedMethodNotifier;
  late final ValueNotifier<double> _targetAmountNotifier;
  late final ValueNotifier<int> _targetDaysNotifier;

  final ValueNotifier<String?> _selectedCurrency = ValueNotifier(null);
  final ValueNotifier<Color> _selectedColor = ValueNotifier(Color(0xFF4CAF50));

  @override
  void initState() {
    super.initState();
    _targetDateNotifier =
        ValueNotifier(DateTime.now().add(const Duration(days: 30)));
    _isByAmountNotifier = ValueNotifier(true);
    _selectedMethodNotifier = ValueNotifier(SavingsMethod.defaultPattern);
    _targetAmountNotifier = ValueNotifier(0.0);
    _targetDaysNotifier = ValueNotifier(30);

    _selectedCurrency.value = context
        .read<SettingsBloc>()
        .state
        .model
        .defaultCurrency;

    _daysFocusNode.addListener(() {
      if (!_daysFocusNode.hasFocus && !_isByAmountNotifier.value) {
        _calculateDateFromDays();
      }
    });
  }

  void _calculateDateFromDays() {
    final days = int.tryParse(_daysController.text) ?? 0;
    if (days > 0) {
      _targetDateNotifier.value = DateTime.now().add(Duration(days: days));
      _updateCalculations();
    }
  }

  void _updateCalculations() {
    if (_selectedMethodNotifier.value == SavingsMethod.custom) return;

    if (_isByAmountNotifier.value) {
      // Amount -> Days
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      _targetAmountNotifier.value = amount;
      if (amount > 0) {
        int days = 0;
        if (_selectedMethodNotifier.value == SavingsMethod.defaultPattern) {
          days = ((-1 + sqrt(1 + 8 * amount)) / 2).ceil();
        } else if (_selectedMethodNotifier.value == SavingsMethod.doublePattern) {
          days = ((-1 + sqrt(1 + 4 * amount)) / 2).ceil();
        } else if (_selectedMethodNotifier.value == SavingsMethod.constant) {
          final constant = double.tryParse(_constantController.text) ?? 1.0;
          days = (amount / (constant > 0 ? constant : 1.0)).ceil();
        }
        _daysController.text = days.toString();
        _targetDaysNotifier.value = days;
        _targetDateNotifier.value = DateTime.now().add(Duration(days: days));
      }
    } else {
      // Days -> Amount
      final days = int.tryParse(_daysController.text) ?? 0;
      _targetDaysNotifier.value = days;
      if (days > 0) {
        double amount = 0;
        if (_selectedMethodNotifier.value == SavingsMethod.defaultPattern) {
          amount = (days * (days + 1)) / 2;
        } else if (_selectedMethodNotifier.value == SavingsMethod.doublePattern) {
          amount = days * (days + 1);
        } else if (_selectedMethodNotifier.value == SavingsMethod.constant) {
          final constant = double.tryParse(_constantController.text) ?? 1.0;
          amount = days * constant;
        }
        _amountController.text = NumberFormat('#,###.##').format(amount);
        _targetAmountNotifier.value = amount;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _daysController.dispose();
    _constantController.dispose();
    _amountFocusNode.dispose();
    _daysFocusNode.dispose();
    _selectedCurrency.dispose();
    _selectedColor.dispose();
    _targetDateNotifier.dispose();
    _isByAmountNotifier.dispose();
    _selectedMethodNotifier.dispose();
    _targetAmountNotifier.dispose();
    _targetDaysNotifier.dispose();
    super.dispose();
  }

  void _showHelpPopup(SavingsMethod method) {
    final l10n = AppLocalizations.of(context)!;
    String title = "";
    String description = "";
    switch (method) {
      case SavingsMethod.defaultPattern:
        title = l10n.methodDefaultTitle;
        description = l10n.methodDefaultDesc;
        break;
      case SavingsMethod.constant:
        title = l10n.methodConstantTitle;
        description = l10n.methodConstantDesc;
        break;
      case SavingsMethod.doublePattern:
        title = l10n.methodDoubleTitle;
        description = l10n.methodDoubleDesc;
        break;
      case SavingsMethod.custom:
        title = l10n.methodCustomTitle;
        description = l10n.methodCustomDesc;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(title, style: AppTextStyles.heading3),
        content: Text(description, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(l10n.newSavingGoal, style: AppTextStyles.heading2),
        leading: CloseButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Toggle Amount/Days
                    SavingsModeToggle(
                      isByAmountNotifier: _isByAmountNotifier,
                      amountFocusNode: _amountFocusNode,
                      daysFocusNode: _daysFocusNode,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GoalNameInput(controller: _nameController),
                    const SizedBox(height: AppSpacing.lg),

                    // Target Amount Input
                    TargetAmountInput(
                      isByAmountNotifier: _isByAmountNotifier,
                      selectedMethodNotifier: _selectedMethodNotifier,
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      selectedCurrencyNotifier: _selectedCurrency,
                      onChanged: _updateCalculations,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Number of Days Input
                    TargetDaysInput(
                      isByAmountNotifier: _isByAmountNotifier,
                      selectedMethodNotifier: _selectedMethodNotifier,
                      controller: _daysController,
                      focusNode: _daysFocusNode,
                      onChanged: () {
                        if (!_isByAmountNotifier.value) {
                          _updateCalculations();
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Method Selection Label
                    Text(l10n.calculationMethod,
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                  ]),
                ),
              ),

              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: CalculationMethodGrid(
                  selectedMethodNotifier: _selectedMethodNotifier,
                  onMethodSelected: (m) {
                    _selectedMethodNotifier.value = m;
                    _updateCalculations();
                  },
                  onHelp: _showHelpPopup,
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ListenableBuilder(
                      listenable: _selectedMethodNotifier,
                      builder: (context, _) {
                        final method = _selectedMethodNotifier.value;
                        if (method != SavingsMethod.constant) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            CustomTextField(
                              hintText: l10n.dailySavingAmount,
                              controller: _constantController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _updateCalculations(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        );
                      },
                    ),

                    Text(l10n.targetDate, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    TargetDateDisplay(
                      targetDateNotifier: _targetDateNotifier,
                      isByAmountNotifier: _isByAmountNotifier,
                      selectedMethodNotifier: _selectedMethodNotifier,
                      onPickDate: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _targetDateNotifier.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _targetDateNotifier.value = picked;
                          final diff =
                              picked.difference(DateTime.now()).inDays + 1;
                          _daysController.text = diff.toString();
                          _targetDaysNotifier.value = diff;
                        }
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    SavingsColorPicker(
                      selectedColorNotifier: _selectedColor,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    // Dynamic Info Text
                    SavingsInfoSection(isByAmountNotifier: _isByAmountNotifier),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(text: l10n.createGoal, onPressed: _submit),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = _targetAmountNotifier.value;
      final days = _targetDaysNotifier.value;

      if (amount <= 0 && _isByAmountNotifier.value) return;
      if (days <= 0 && !_isByAmountNotifier.value) return;

      final model = SavingsModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        targetAmount: amount,
        targetDays: days,
        method: _selectedMethodNotifier.value,
        constantAmount: double.tryParse(_constantController.text),
        currency: _selectedCurrency.value!,
        targetDate: _targetDateNotifier.value,
        colorValue: _selectedColor.value.toARGB32(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<SavingsBloc>().add(SavingsEventCreateGoal(model: model));
      Navigator.pop(context);
    }
  }
}

