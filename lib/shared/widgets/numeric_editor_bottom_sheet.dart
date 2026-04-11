import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericEditorBottomSheet extends StatefulWidget {
  final String title;
  final String? description;
  final double initialValue;
  final String? suffixText;
  final Function(double) onSave;
  final VoidCallback? onReset;

  const NumericEditorBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.initialValue,
    this.suffixText,
    required this.onSave,
    this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? description,
    required double initialValue,
    String? suffixText,
    required Function(double) onSave,
    VoidCallback? onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NumericEditorBottomSheet(
        title: title,
        description: description,
        initialValue: initialValue,
        suffixText: suffixText,
        onSave: onSave,
        onReset: onReset,
      ),
    );
  }

  @override
  State<NumericEditorBottomSheet> createState() =>
      _NumericEditorBottomSheetState();
}

class _NumericEditorBottomSheetState extends State<NumericEditorBottomSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0 ? '' : widget.initialValue.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final l10n = AppLocalizations.of(context)!;
    final value = double.tryParse(_controller.text);

    if (value == null) {
      setState(() => _errorText = l10n.invalidAmount);
      return;
    }

    if (value < 0) {
      setState(
        () => _errorText = l10n.invalidAmount,
      ); // Or a specific "must be positive" message
      return;
    }

    widget.onSave(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: widget.title,
      description: widget.description,
      onSave: _validateAndSave,
      onReset: widget.onReset,
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        style: AppTextStyles.bodyLarge,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
        ],
        decoration: InputDecoration(
          suffixText: widget.suffixText,
          errorText: _errorText,
          filled: true,
          fillColor: AppColors.primaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.primaryAccent),
          ),
        ),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
      ),
    );
  }
}
