import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class AddExpenseScreen extends StatefulWidget {
  static const String routeName = '/add-expense';

  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  // Dummy categories
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSave() {
    // TODO: Implement save expense logic
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Add Expense",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              Text("Amount", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: "Enter amount",
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icon(PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular), color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Dropdown
              Text("Category", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: Text("Select Category", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    isExpanded: true,
                    dropdownColor: AppColors.cardBackground,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: AppTextStyles.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Picker
              Text("Date", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular), color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat.yMMMd().format(_selectedDate),
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notes Input
              Text("Notes", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: "Add notes (optional)",
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Button
              CustomButton(
                text: "Add Expense",
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
