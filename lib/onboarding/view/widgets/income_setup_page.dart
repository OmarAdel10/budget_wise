import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';

class IncomeSetupPage extends StatefulWidget {
  final Function(double amount, String source) onDataChanged;

  const IncomeSetupPage({super.key, required this.onDataChanged});

  @override
  State<IncomeSetupPage> createState() => _IncomeSetupPageState();
}

class _IncomeSetupPageState extends State<IncomeSetupPage> {
  final TextEditingController _amountController = TextEditingController();
  final List<String> _incomeSources = ['Work', 'Personal', 'Freelance', 'Other'];
  String? _selectedSource;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateData);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateData() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_selectedSource != null) {
      widget.onDataChanged(amount, _selectedSource!);
    }
  }

  // Helper to get localized source name
  String _getLocalizedSource(BuildContext context, String sourceKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (sourceKey) {
      case 'Work': return l10n.sourceWork;
      case 'Personal': return l10n.sourcePersonal;
      case 'Freelance': return l10n.sourceFreelance;
      case 'Other': return l10n.sourceOther;
      default: return sourceKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to start
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center( // Center Title
            child: Text(
              l10n.incomeSetupTitle,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
              child: Text(
            l10n.incomeSetupDesc,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: AppSpacing.xl * 2),
      
          // Amount Input
          Text(l10n.incomeAmountLabel, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          CustomTextField(
            hintText: "0.00",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixIcon: const Icon(Icons.attach_money, color: AppColors.textSecondary),
          ),
          
          const SizedBox(height: AppSpacing.lg),

          // Source Selection
          Text(l10n.incomeSourceLabel, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _incomeSources.map((source) {
              final isSelected = _selectedSource == source;
              return ChoiceChip(
                label: Text(
                  _getLocalizedSource(context, source),
                  style: TextStyle(
                    color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSource = selected ? source : null;
                    _updateData();
                  });
                },
                selectedColor: AppColors.primaryAccent,
                backgroundColor: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryAccent : AppColors.borderColor,
                  ),
                ),
                checkmarkColor: AppColors.textInverse,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
