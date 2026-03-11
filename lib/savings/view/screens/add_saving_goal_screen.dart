import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view_model/savings_bloc.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

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
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  final ValueNotifier<String?> _selectedCurrency = ValueNotifier(null);
  final ValueNotifier<int> _selectedColor = ValueNotifier(0xFF4CAF50); // Default Green

  final List<int> _colorOptions = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFFFC107, // Amber
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFFFF5722, // Deep Orange
    0xFF00BCD4, // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _selectedCurrency.value =
        context.read<SettingsBloc>().state.model.defaultCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _selectedCurrency.dispose();
    _selectedColor.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAccent,
              onPrimary: AppColors.textInverse,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _createGoal() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final targetAmount = double.tryParse(
            _amountController.text.replaceAll(',', ''),
          ) ??
          0.0;

      if (targetAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.enterValidAmount)),
        );
        return;
      }

      final newGoal = SavingsModel(
        id: const Uuid().v4(),
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        currency: _selectedCurrency.value!,
        targetDate: _targetDate,
        colorValue: _selectedColor.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<SavingsBloc>().add(SavingsEventCreateGoal(model: newGoal));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.newSavingGoal,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                // Goal Name Input
                Text(l10n.goalName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                CustomTextField(
                  hintText: l10n.enterGoalName,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Target Amount Input
                Text(l10n.targetAmount, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                CustomTextField(
                  hintText: l10n.enterAmount,
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ThousandsSeparatorInputFormatter(),
                  ],
                  prefixIcon: CurrencyPrefix(
                    selectedCurrencyNotifier: _selectedCurrency,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterValidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Color Selection
                Text(l10n.categoryChart, style: AppTextStyles.bodyMedium), // Using categoryChart as a proxy for "Goal Color" or "Color"
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 50,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _selectedColor,
                    builder: (context, selectedColor, _) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colorOptions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final colorValue = _colorOptions[index];
                          final isSelected = selectedColor == colorValue;

                          return GestureDetector(
                            onTap: () => _selectedColor.value = colorValue,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(colorValue),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.textPrimary,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Color(colorValue).withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Target Date Picker
                Text(l10n.targetDate, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          DateFormat.yMMMd().format(_targetDate),
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(PhosphorIconsStyle.regular),
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.savingRegularlyInfo,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save Button
                CustomButton(
                  text: l10n.createGoal,
                  onPressed: _createGoal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
