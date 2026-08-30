import 'package:budget_wise/currency_conversions/view_model/currency_bloc.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/numeric_editor_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';

class CurrencyConversionPreview extends StatefulWidget {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final Function(double) onConvertedAmountChanged;

  const CurrencyConversionPreview({
    super.key,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onConvertedAmountChanged,
  });

  @override
  State<CurrencyConversionPreview> createState() =>
      _CurrencyConversionPreviewState();
}

class _CurrencyConversionPreviewState extends State<CurrencyConversionPreview> {
  double? _manualOverride;
  late double _calculatedAmount;

  @override
  void initState() {
    super.initState();
    _updateCalculation();
  }

  @override
  void didUpdateWidget(CurrencyConversionPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.fromCurrency != widget.fromCurrency ||
        oldWidget.toCurrency != widget.toCurrency) {
      _updateCalculation();
    }
  }

  void _updateCalculation() {
    final settings = context.read<SettingsBloc>().state.model;
    final currencyBloc = context.read<CurrencyBloc>();

    _calculatedAmount = currencyBloc.convert(
      amount: widget.amount,
      from: widget.fromCurrency,
      to: widget.toCurrency,
      margin: settings.bankMargin,
    );

    // If no manual override, notify parent of the calculated amount
    if (_manualOverride == null) {
      widget.onConvertedAmountChanged(_calculatedAmount);
    }
  }

  void _showOverrideBottomSheet() {
    NumericEditorBottomSheet.show(
      context,
      title: context.l10n.manualOverride,
      description: 'Enter the exact amount deducted from your account:',
      initialValue: _manualOverride ?? _calculatedAmount,
      suffixText: widget.toCurrency,
      onReset: () {
        setState(() {
          _manualOverride = null;
          widget.onConvertedAmountChanged(_calculatedAmount);
        });
        Navigator.pop(context);
      },
      onSave: (value) {
        setState(() {
          _manualOverride = value;
          widget.onConvertedAmountChanged(value);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fromCurrency == widget.toCurrency || widget.amount == 0) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        if (state is CurrencyInitial || state is CurrencyLoading) {
          if (state is CurrencyInitial) {
            context.read<CurrencyBloc>().add(
              CurrencyLoadRequested(baseCurrency: widget.fromCurrency),
            );
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(child: LinearProgressIndicator(minHeight: 2)),
          );
        }

        if (state is CurrencyError) {
          return InkWell(
            onTap: () => context.read<CurrencyBloc>().add(
              CurrencyLoadRequested(baseCurrency: widget.fromCurrency),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.warning,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.conversionError,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.retry,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final displayAmount = _manualOverride ?? _calculatedAmount;
        final isOverridden = _manualOverride != null;
        final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);

        return InkWell(
          onTap: _showOverrideBottomSheet,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  PhosphorIconsRegular.currencyCircleDollar,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOverridden
                            ? context.l10n.manualConversion
                            : context.l10n.estimatedConversion,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${formatter.format(displayAmount)} ${widget.toCurrency}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverridden
                              ? AppColors.primaryAccent
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isOverridden
                      ? PhosphorIconsRegular.pencilSimple
                      : PhosphorIconsRegular.caretRight,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
