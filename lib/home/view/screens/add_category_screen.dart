import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/icon_picker_bottom_sheet.dart';

class AddCategoryScreen extends StatefulWidget {
  static const String routeName = '/add-category';

  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  IconData _selectedIcon = PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill);

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _onSave() {
    // TODO: Implement save category logic
    Navigator.of(context).pop();
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.5,
        child: IconPickerBottomSheet(
          onIconSelected: (icon) {
            setState(() {
              _selectedIcon = icon;
            });
          },
        ),
      ),
    );
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
          "Add Category",
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
              // Icon Selection
              Center(
                child: GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryAccent),
                    ),
                    child: Icon(
                      _selectedIcon,
                      size: 40,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
               Center(
                child: Text(
                  "Tap to change icon",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Name Input
              Text("Category Name", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: "e.g., Shopping",
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget Input
              Text("Monthly Budget", style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              CustomTextField(
                hintText: "Amount",
                controller: _budgetController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Button
              CustomButton(
                text: "Create Category",
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
