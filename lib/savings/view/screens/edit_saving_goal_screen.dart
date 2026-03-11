import 'dart:math';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view_model/savings_view_model.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class EditSavingGoalScreen extends StatefulWidget {
  static const String routeName = '/edit-saving-goal';
  final SavingsModel goal;

  const EditSavingGoalScreen({super.key, required this.goal});

  @override
  State<EditSavingGoalScreen> createState() => _EditSavingGoalScreenState();
}

class _EditSavingGoalScreenState extends State<EditSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _daysController;
  late TextEditingController _constantController;

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _daysFocusNode = FocusNode();

  late DateTime _targetDate;
  bool _isByAmount = true;
  late SavingsMethod _selectedMethod;

  final ValueNotifier<String?> _selectedCurrency = ValueNotifier(null);
  final ValueNotifier<int> _selectedColor = ValueNotifier(0xFF4CAF50);

  final List<int> _colorOptions = [
    0xFF4CAF50,
    0xFF2196F3,
    0xFFFFC107,
    0xFFE91E63,
    0xFF9C27B0,
    0xFFFF5722,
    0xFF00BCD4,
  ];

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _nameController = TextEditingController(text: goal.name);
    _amountController = TextEditingController(
      text: NumberFormat('#,###.##').format(goal.targetAmount),
    );
    _daysController = TextEditingController(text: goal.targetDays.toString());
    _constantController = TextEditingController(
      text: goal.constantAmount?.toString() ?? '',
    );
    _targetDate = goal.targetDate;
    _selectedMethod = goal.method;
    _selectedCurrency.value = goal.currency;
    _selectedColor.value = goal.colorValue;

    _daysFocusNode.addListener(() {
      if (!_daysFocusNode.hasFocus && !_isByAmount) {
        _calculateDateFromDays();
      }
    });
  }

  void _calculateDateFromDays() {
    final days = int.tryParse(_daysController.text) ?? 0;
    if (days > 0) {
      setState(() {
        _targetDate = DateTime.now().add(Duration(days: days));
      });
      _updateCalculations();
    }
  }

  void _updateCalculations() {
    if (_selectedMethod == SavingsMethod.custom) return;

    if (_isByAmount) {
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      if (amount > 0) {
        int days = 0;
        if (_selectedMethod == SavingsMethod.defaultPattern) {
          days = ((-1 + sqrt(1 + 8 * amount)) / 2).ceil();
        } else if (_selectedMethod == SavingsMethod.doublePattern) {
          days = ((-1 + sqrt(1 + 4 * amount)) / 2).ceil();
        } else if (_selectedMethod == SavingsMethod.constant) {
          final constant = double.tryParse(_constantController.text) ?? 1.0;
          days = (amount / (constant > 0 ? constant : 1.0)).ceil();
        }
        _daysController.text = days.toString();
        _targetDate = DateTime.now().add(Duration(days: days));
      }
    } else {
      final days = int.tryParse(_daysController.text) ?? 0;
      if (days > 0) {
        double amount = 0;
        if (_selectedMethod == SavingsMethod.defaultPattern) {
          amount = (days * (days + 1)) / 2;
        } else if (_selectedMethod == SavingsMethod.doublePattern) {
          amount = days * (days + 1);
        } else if (_selectedMethod == SavingsMethod.constant) {
          final constant = double.tryParse(_constantController.text) ?? 1.0;
          amount = days * constant;
        }
        _amountController.text = NumberFormat('#,###.##').format(amount);
      }
    }
    setState(() {});
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
    super.dispose();
  }

  void _showHelpPopup(SavingsMethod method) {
    String title = "";
    String description = "";
    switch (method) {
      case SavingsMethod.defaultPattern:
        title = "Default Method";
        description =
            "Save an increasing amount every day: Day 1 = \$1, Day 2 = \$2, etc.";
        break;
      case SavingsMethod.constant:
        title = "Constant Method";
        description =
            "Save a fixed amount every single day (e.g., \$10 every day).";
        break;
      case SavingsMethod.doublePattern:
        title = "2x Default Method";
        description =
            "Double the default pattern: Day 1 = \$2, Day 2 = \$4, etc.";
        break;
      case SavingsMethod.custom:
        title = "Custom Method";
        description =
            "Add manual entries whenever you want. Complete flexibility!";
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
            child: const Text("Got it"),
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
        title: Text(l10n.edit, style: AppTextStyles.heading2),
        leading: BackButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle Amount/Days
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleButton(
                          text: "Set by Amount",
                          isSelected: _isByAmount,
                          onTap: () {
                            setState(() => _isByAmount = true);
                            _amountFocusNode.requestFocus();
                          },
                        ),
                      ),
                      Expanded(
                        child: _ToggleButton(
                          text: "Set by Days",
                          isSelected: !_isByAmount,
                          onTap: () {
                            setState(() => _isByAmount = false);
                            _daysFocusNode.requestFocus();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
                  hintText: l10n.goalName,
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Target Amount Input
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      _isByAmount || _selectedMethod == SavingsMethod.custom
                      ? 1.0
                      : 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.targetAmount, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      CustomTextField(
                        hintText: l10n.enterAmount,
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: TextInputType.number,
                        readOnly:
                            !_isByAmount &&
                            _selectedMethod != SavingsMethod.custom,
                        bgColor:
                            !_isByAmount &&
                                _selectedMethod != SavingsMethod.custom
                            ? AppColors.secondaryBackground
                            : null,
                        prefixIcon: CurrencyPrefix(
                          selectedCurrencyNotifier: _selectedCurrency,
                        ),
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        onChanged: (_) => _updateCalculations(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Number of Days Input
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      !_isByAmount ||
                          (_isByAmount &&
                              _selectedMethod == SavingsMethod.custom)
                      ? 1.0
                      : 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Number of Days", style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      CustomTextField(
                        hintText: "Enter Days",
                        controller: _daysController,
                        focusNode: _daysFocusNode,
                        keyboardType: TextInputType.number,
                        readOnly:
                            _isByAmount &&
                            _selectedMethod != SavingsMethod.custom,
                        bgColor:
                            _isByAmount &&
                                _selectedMethod != SavingsMethod.custom
                            ? AppColors.secondaryBackground
                            : null,
                        onChanged: (_) {
                          if (!_isByAmount) {
                            _updateCalculations();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Method Selection
                Text("Calculation Method", style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: SavingsMethod.values
                      .map(
                        (m) => _MethodCard(
                          method: m,
                          isSelected: _selectedMethod == m,
                          onTap: () {
                            setState(() => _selectedMethod = m);
                            _updateCalculations();
                          },
                          onHelp: () => _showHelpPopup(m),
                        ),
                      )
                      .toList(),
                ),

                if (_selectedMethod == SavingsMethod.constant) ...[
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    hintText: "Daily Saving Amount",
                    controller: _constantController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateCalculations(),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                Text(l10n.targetDate, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                RepaintBoundary(
                  child: _DateDisplay(
                    date: _targetDate,
                    onTap:
                        _isByAmount && _selectedMethod == SavingsMethod.custom
                        ? () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _targetDate = picked;
                                final diff =
                                    _targetDate
                                        .difference(DateTime.now())
                                        .inDays +
                                    1;
                                _daysController.text = diff.toString();
                              });
                            }
                          }
                        : null,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                Text('Color Picker', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                _ColorPicker(
                  selectedColor: _selectedColor,
                  options: _colorOptions,
                ),

                const SizedBox(height: AppSpacing.xl),
                CustomButton(text: l10n.saveChanges, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      final days = int.tryParse(_daysController.text) ?? 0;

      if (amount <= 0 && _isByAmount) return;
      if (days <= 0 && !_isByAmount) return;

      final updatedGoal = widget.goal.copyWith(
        name: _nameController.text.trim(),
        targetAmount: amount,
        targetDays: days,
        method: _selectedMethod,
        constantAmount: double.tryParse(_constantController.text),
        currency: _selectedCurrency.value!,
        targetDate: _targetDate,
        colorValue: _selectedColor.value,
        updatedAt: DateTime.now(),
      );

      context.read<SavingsBloc>().add(SavingsEventEditGoal(model: updatedGoal));
      Navigator.pop(context);
    }
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final SavingsMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onHelp;
  const _MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    String label = "";
    switch (method) {
      case SavingsMethod.defaultPattern:
        label = "Default";
        break;
      case SavingsMethod.constant:
        label = "Constant";
        break;
      case SavingsMethod.doublePattern:
        label = "2x Default";
        break;
      case SavingsMethod.custom:
        label = "Custom";
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.borderColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onHelp,
                child: const Icon(
                  Icons.help_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDisplay extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onTap;
  const _DateDisplay({required this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: RepaintBoundary(
        child: Opacity(
          opacity: onTap == null ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  DateFormat.yMMMd().format(date),
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final ValueNotifier<int> selectedColor;
  final List<int> options;
  const _ColorPicker({required this.selectedColor, required this.options});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedColor,
      builder: (context, current, _) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => selectedColor.value = options[i],
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(options[i]),
                  shape: BoxShape.circle,
                  border: current == options[i]
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: current == options[i]
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
