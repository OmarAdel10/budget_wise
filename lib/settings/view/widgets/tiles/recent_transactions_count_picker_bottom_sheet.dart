import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class RecentTransactionsCountPickerBottomSheet extends StatefulWidget {
  final int selectedCount;
  final ValueChanged<int> onCountSelected;
  final Color selectionColor;

  const RecentTransactionsCountPickerBottomSheet({
    super.key,
    required this.selectedCount,
    required this.onCountSelected,
    this.selectionColor = AppColors.primaryAccent,
  });

  @override
  State<RecentTransactionsCountPickerBottomSheet> createState() =>
      _RecentTransactionsCountPickerBottomSheetState();
}

class _RecentTransactionsCountPickerBottomSheetState
    extends State<RecentTransactionsCountPickerBottomSheet> {
  static const List<int> _options = [
    5,
    10,
    20,
    50,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
  ];
  late final ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    final index = _options.indexOf(widget.selectedCount);
    _currentIndex = ValueNotifier<int>(
      index >= 0 ? index : _options.indexOf(50),
    );
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  void _goToFirst() {
    if (_currentIndex.value != 0) {
      _currentIndex.value = 0;
      widget.onCountSelected(_options[0]);
    }
  }

  void _goToLast() {
    final last = _options.length - 1;
    if (_currentIndex.value != last) {
      _currentIndex.value = last;
      widget.onCountSelected(_options[last]);
    }
  }

  void _decrement() {
    if (_currentIndex.value > 0) {
      _currentIndex.value = _currentIndex.value - 1;
      widget.onCountSelected(_options[_currentIndex.value]);
    }
  }

  void _increment() {
    if (_currentIndex.value < _options.length - 1) {
      _currentIndex.value = _currentIndex.value + 1;
      widget.onCountSelected(_options[_currentIndex.value]);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          const SizedBox(height: AppSpacing.sm),
          Text(context.l10n.recentTransactionsCount, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.xl),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) => _StepperButton(
                    icon: PhosphorIconsRegular.caretDoubleLeft,
                    onTap: index > 0 ? _goToFirst : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) => _StepperButton(
                    icon: PhosphorIconsRegular.minus,
                    onTap: index > 0 ? _decrement : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) => Text(
                    _options[index].toString(),
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 40,
                      color: widget.selectionColor,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) => _StepperButton(
                    icon: PhosphorIconsRegular.plus,
                    onTap: index < _options.length - 1 ? _increment : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) => _StepperButton(
                    icon: PhosphorIconsRegular.caretDoubleRight,
                    onTap: index < _options.length - 1 ? _goToLast : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            context.l10n.recentTransactionsCountInfo,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final PhosphorIconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled
              ? AppColors.textSecondary.withValues(alpha: 0.1)
              : AppColors.primaryAccent.withValues(alpha: 0.15),
          border: Border.all(
            color: disabled
                ? AppColors.textSecondary.withValues(alpha: 0.2)
                : AppColors.primaryAccent.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: disabled
              ? AppColors.textSecondary.withValues(alpha: 0.3)
              : AppColors.primaryAccent,
        ),
      ),
    );
  }
}
