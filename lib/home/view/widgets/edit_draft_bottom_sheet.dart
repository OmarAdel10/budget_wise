import 'package:budget_wise/accounts/view/widgets/currency_picker_bottom_sheet.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditDraftBottomSheet extends StatefulWidget {
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String currency;

  const EditDraftBottomSheet({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.currency,
  });

  @override
  State<EditDraftBottomSheet> createState() => _EditDraftBottomSheetState();
}

class _EditDraftBottomSheetState extends State<EditDraftBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late TransactionType selectedType;
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    amountController = TextEditingController(text: widget.amount.toString());
    selectedDate = widget.date;
    selectedTime = TimeOfDay.fromDateTime(widget.date);
    selectedType = widget.type;
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.editDraft,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title Field
          _buildLabel(l10n.title),
          _buildTextField(
            controller: titleController,
            hint: widget.title,
            icon: PhosphorIcons.tag(),
            isAmount: false,
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount Field
          _buildLabel(l10n.transactionAmount),
          _buildTextField(
            controller: amountController,
            hint: widget.amount.toString(),
            // icon: PhosphorIcons.currencyDollar(),
            isAmount: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date and Time Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(l10n.date),
                    _buildPickerTile(
                      text: DateFormat('dd/MM/yyyy').format(selectedDate),
                      icon: PhosphorIcons.calendar(),
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(l10n.time),
                    _buildPickerTile(
                      text: selectedTime.format(context),
                      icon: PhosphorIcons.clock(),
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Type Switch
          _buildLabel(l10n.transactionType),
          Row(
            children: [
              _buildTypeButton(TransactionType.expense, l10n.expenses),
              const SizedBox(width: AppSpacing.md),
              _buildTypeButton(TransactionType.income, l10n.income),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          ElevatedButton(
            onPressed: () {
              final finalDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              Navigator.pop(context, {
                'title': titleController.text,
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'date': finalDate,
                'type': selectedType,
                'currency': selectedCurrency,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.saveChanges,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    required bool isAmount,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: isAmount
              ? GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => CurrencyPickerBottomSheet(
                        selectedCurrency: selectedCurrency,
                        onCurrencySelected: (currency) {
                          setState(() => selectedCurrency = currency);
                        },
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedCurrency,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                )
              : Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => controller.clear(),
            color: AppColors.textSecondary,
          ),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(text, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label) {
    final isSelected = selectedType == type;
    final color = type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? color : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
