import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Color? activeColor;
  final ValueChanged<String>? onChanged;
  final Color? bgColor;
  final FocusNode? focusNode;
  final bool shouldUnfocusOnTapOutside;
  final String? label;
  final bool hasOriginalInputDecoration;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.inputFormatters,
    this.activeColor,
    this.onChanged,
    this.bgColor,
    this.focusNode,
    this.shouldUnfocusOnTapOutside = true,
    this.label,
    this.hasOriginalInputDecoration = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: widget.hasOriginalInputDecoration ? null : BoxDecoration(
            color: widget.bgColor ?? AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:AppColors.borderColor,
              width: 0.2,
            ),
            boxShadow: [AppBoxShadow()],
          ),
          child: TextFormField(
            enabled: widget.enabled,
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            style: AppTextStyles.bodyLarge,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onTapOutside:
                widget.shouldUnfocusOnTapOutside
                    ? (event) => FocusScope.of(context).unfocus()
                    : null,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              filled: widget.hasOriginalInputDecoration,
              fillColor: widget.hasOriginalInputDecoration ? null : Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                      : widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
