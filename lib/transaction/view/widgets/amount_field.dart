import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/transaction/view/screens/currency_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AmountField extends StatefulWidget {
  final TextEditingController amountController;
  final ValueNotifier<String?> selectedCurrency;
  final bool enableAutoFocus;
  final bool readOnly;
  const AmountField({
    super.key,
    required this.amountController,
    required this.selectedCurrency,
    this.enableAutoFocus = true,
    this.readOnly = false,
  });

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField>
    with SingleTickerProviderStateMixin {
  final FocusNode _amountFieldAutoFocusNode = FocusNode();
  bool _isFocusedOnce = false;

  late AnimationController _fontSizeController;
  late Animation<double> _fontSizeAnimation;
  double _currentFontSize = 44.0;
  late final String defaultCurrency;

  @override
  void initState() {
    super.initState();
    defaultCurrency = context.read<SettingsBloc>().state.currencySymbol;
    _fontSizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _fontSizeAnimation = Tween<double>(begin: 44.0, end: 44.0).animate(
      CurvedAnimation(parent: _fontSizeController, curve: Curves.easeOutCubic),
    );

    widget.amountController.addListener(_updateFontSize);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.enableAutoFocus && !_isFocusedOnce) {
          _amountFieldAutoFocusNode.requestFocus();
          _isFocusedOnce = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _amountFieldAutoFocusNode.dispose();
    _fontSizeController.dispose();
    widget.amountController.removeListener(_updateFontSize);
    super.dispose();
  }

  void _updateFontSize() {
    final String text = widget.amountController.text;
    if (text.isEmpty) {
      _animateFontSize(44.0);
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.heading1.copyWith(fontSize: 44.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final maxAvailableWidth = MediaQuery.of(context).size.width * 0.4;

    if (textPainter.width > maxAvailableWidth) {
      final scale = maxAvailableWidth / textPainter.width;
      final targetSize = (44.0 * scale).clamp(30.0, 44.0);
      _animateFontSize(targetSize);
    } else {
      _animateFontSize(44.0);
    }
  }

  void _animateFontSize(double targetSize) {
    if (_currentFontSize == targetSize) return;
    _fontSizeAnimation = Tween<double>(begin: _currentFontSize, end: targetSize)
        .animate(
          CurvedAnimation(
            parent: _fontSizeController,
            curve: Curves.easeOutCubic,
          ),
        );
    _currentFontSize = targetSize;
    _fontSizeController.forward(from: 0.0);
  }

  void _onCurrencyTap() {
    Navigator.of(context).push(
      BottomSheetService.pageRoute(
        child: (context) {
          final scrollController = PrimaryScrollController.of(context);
          return CurrencySelectionScreen(
            scrollController: scrollController,
            selectedCurrency: widget.selectedCurrency.value ?? '',
            onCurrencySelect: (code) {
              widget.selectedCurrency.value = code;
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _onCurrencyTap,
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                const Icon(
                  PhosphorIconsRegular.caretDown,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                ValueListenableBuilder<String?>(
                  valueListenable: widget.selectedCurrency,
                  builder: (context, currency, _) {
                    return Text(
                      currency ?? defaultCurrency,
                      style: AppTextStyles.heading1.copyWith(fontSize: 34),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        IntrinsicWidth(
          child: GestureDetector(
            onTap: () {
              if (widget.readOnly) {
                AppToast.show(
                  context,
                  type: AppToastType.error,
                  title: 'Cannot change amount',
                );
              }
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: AnimatedBuilder(
                animation: _fontSizeAnimation,
                builder: (context, child) => TextField(
                  controller: widget.amountController,
                  focusNode: _amountFieldAutoFocusNode,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  textAlignVertical: TextAlignVertical.center,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: _fontSizeAnimation.value,
                    color: widget.readOnly
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    ThousandsSeparatorInputFormatter(),
                  ],
                  readOnly: widget.readOnly,
                  showCursor: true,
                  cursorColor: AppColors.primaryAccent,
                  cursorHeight: 50,
                  cursorWidth: 2.5,
                  cursorRadius: const Radius.circular(2.0),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTextStyles.heading1.copyWith(
                      fontSize: 44,
                      color: AppColors.borderColor,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
      ],
    );
  }
}
