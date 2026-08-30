import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

// ---------------------------------------------------------------------------
// Internal data carrier for one tab option's display properties
// ---------------------------------------------------------------------------

class TabItemData {
  final String text;
  final Color color;
  final IconData icon;
  final IconData activeIcon;

  const TabItemData({
    required this.text,
    required this.color,
    required this.icon,
    required this.activeIcon,
  });
}

// ---------------------------------------------------------------------------
// Unified generic tab bar
// ---------------------------------------------------------------------------

/// A pill-style tab bar that works with any [Enum] type.
///
/// Use the named static methods for the most common cases:
/// - [TypeTabBar.forToggleOptions] – works with [ToggleOption] (income,
///   expense, transfer, savings, subscription).
/// - [TypeTabBar.forTransactionTypes] – works with [TransactionType] (income,
///   expense, transfer) and supports the [enableTransferTab] flag.
///
/// When [views] are provided the widget renders a [TabBarView] below the tabs.
/// Without [views] it renders only the tab strip.
class TypeTabBar<T extends Enum> extends StatefulWidget {
  final List<T> options;
  final TabItemData Function(BuildContext context, T option, bool isSelected)
  itemBuilder;
  final TabController? controller;
  final ValueNotifier<T>? selectionNotifier;
  final void Function(T)? onChanged;
  final List<Widget>? views;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isScrollable;

  const TypeTabBar._({
    super.key,
    required this.options,
    required this.itemBuilder,
    this.controller,
    this.selectionNotifier,
    this.onChanged,
    this.views,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.isScrollable = true,
  });

  /// Creates a [TypeTabBar] that works with [ToggleOption] values.
  ///
  /// The [options] list controls which tabs are shown and their order.
  /// Supports income, expense, transfer, savings, and subscription.
  static TypeTabBar<ToggleOption> forToggleOptions({
    Key? key,
    List<ToggleOption> options = const [
      ToggleOption.income,
      ToggleOption.expense,
    ],
    TabController? controller,
    ValueNotifier<ToggleOption>? selectionNotifier,
    void Function(ToggleOption)? onChanged,
    List<Widget>? views,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
    ),
    bool isScrollable = true,
  }) {
    return TypeTabBar<ToggleOption>._(
      key: key,
      options: options,
      itemBuilder: (context, option, isSelected) {
        return TabItemData(
          text: _toggleOptionLabel(context, option),
          color: _toggleOptionColor(option),
          icon: _toggleOptionIcon(option, isSelected),
          activeIcon: _toggleOptionIcon(option, true),
        );
      },
      controller: controller,
      selectionNotifier: selectionNotifier,
      onChanged: onChanged,
      views: views,
      backgroundColor: backgroundColor,
      padding: padding,
      isScrollable: isScrollable,
    );
  }

  /// Creates a [TypeTabBar] that works with [TransactionType] values.
  ///
  /// When [enableTransferTab] is `false` the transfer option is omitted.
  static TypeTabBar<TransactionType> forTransactionTypes({
    Key? key,
    TabController? controller,
    ValueNotifier<TransactionType>? selectionNotifier,
    void Function(TransactionType)? onChanged,
    List<Widget>? views,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
    ),
    bool isScrollable = true,
    bool enableTransferTab = true,
  }) {
    final options = enableTransferTab
        ? TransactionType.values.toList()
        : TransactionType.values
              .where((t) => t != TransactionType.transfer)
              .toList();

    return TypeTabBar<TransactionType>._(
      key: key,
      options: options,
      itemBuilder: (context, option, isSelected) {
        return TabItemData(
          text: _transactionTypeLabel(context, option),
          color: _transactionTypeColor(option),
          icon: _transactionTypeIcon(option, isSelected),
          activeIcon: _transactionTypeIcon(option, true),
        );
      },
      controller: controller,
      selectionNotifier: selectionNotifier,
      onChanged: onChanged,
      views: views,
      backgroundColor: backgroundColor,
      padding: padding,
      isScrollable: isScrollable,
    );
  }

  @override
  State<TypeTabBar<T>> createState() => _TypeTabBarState<T>();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _TypeTabBarState<T extends Enum> extends State<TypeTabBar<T>>
    with TickerProviderStateMixin {
  TabController? _internalController;
  late final ValueNotifier<int> _indexNotifier;

  TabController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    final initialIdx = _getInitialIndex();
    _indexNotifier = ValueNotifier<int>(initialIdx);
    _initController(initialIdx);
    if (widget.selectionNotifier != null) {
      widget.selectionNotifier!.addListener(_handleNotifierSelection);
    }
  }

  void _initController(int initialIndex) {
    if (widget.controller == null) {
      _internalController = TabController(
        length: widget.options.length,
        vsync: this,
        initialIndex: initialIndex,
      );
    }
    _effectiveController.addListener(_handleTabSelection);
  }

  int _getInitialIndex() {
    if (widget.selectionNotifier != null) {
      final idx = widget.options.indexOf(widget.selectionNotifier!.value);
      return idx != -1 ? idx : 0;
    }
    return 0;
  }

  @override
  void didUpdateWidget(TypeTabBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.length != oldWidget.options.length ||
        widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_handleTabSelection);
      _internalController?.dispose();
      final currentIdx = _indexNotifier.value;
      _initController(currentIdx < widget.options.length ? currentIdx : 0);
    }
  }

  void _handleTabSelection() {
    if (_effectiveController.indexIsChanging) return;

    if (_indexNotifier.value != _effectiveController.index) {
      _indexNotifier.value = _effectiveController.index;
    }

    final selectedOption = widget.options[_effectiveController.index];

    if (widget.selectionNotifier != null &&
        widget.selectionNotifier!.value != selectedOption) {
      widget.selectionNotifier!.removeListener(_handleNotifierSelection);
      widget.selectionNotifier!.value = selectedOption;
      widget.selectionNotifier!.addListener(_handleNotifierSelection);
    }
    widget.onChanged?.call(selectedOption);
  }

  void _handleNotifierSelection() {
    if (widget.selectionNotifier == null) return;

    final index = widget.options.indexOf(widget.selectionNotifier!.value);
    if (index != -1 && index != _effectiveController.index) {
      _effectiveController.animateTo(index);
      _indexNotifier.value = index;
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTabSelection);
    _internalController?.dispose();
    _indexNotifier.dispose();
    widget.selectionNotifier?.removeListener(_handleNotifierSelection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _indexNotifier,
      builder: (context, currentIndex, child) {
        final tabBar = TabBar(
          dividerColor: Colors.transparent,
          controller: _effectiveController,
          isScrollable: widget.isScrollable,
          tabAlignment: widget.isScrollable ? TabAlignment.start : null,
          indicatorColor: Colors.transparent,
          automaticIndicatorColorAdjustment: false,
          splashFactory: NoSplash.splashFactory,
          labelColor: Colors.transparent,
          labelPadding: const EdgeInsets.only(right: AppSpacing.sm),
          padding: widget.padding,
          tabs: widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final data = widget.itemBuilder(
              context,
              option,
              currentIndex == index,
            );
            return _TypeTabBarItem(
              text: data.text,
              isSelected: currentIndex == index,
              color: data.color,
              icon: currentIndex == index ? data.activeIcon : data.icon,
            );
          }).toList(),
          onTap: (index) {
            _indexNotifier.value = index;
          },
        );

        final tabBarContent = widget.backgroundColor != null
            ? Container(color: widget.backgroundColor, child: tabBar)
            : tabBar;

        if (widget.views != null) {
          return Column(
            children: [
              tabBarContent,
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: TabBarView(
                  controller: _effectiveController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: widget.views!,
                ),
              ),
            ],
          );
        }

        return tabBarContent;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab item widget (private)
// ---------------------------------------------------------------------------

class _TypeTabBarItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isSelected;

  const _TypeTabBarItem({
    required this.text,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryAccent.withValues(alpha: 0.1)
            : AppColors.cardBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryAccent
              : AppColors.borderColor.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper functions – ToggleOption
// ---------------------------------------------------------------------------

String _toggleOptionLabel(BuildContext context, ToggleOption option) {
  switch (option) {
    case ToggleOption.income:
      return context.l10n.income;
    case ToggleOption.expense:
      return context.l10n.expenses;
    case ToggleOption.transfer:
      return context.l10n.transfer;
    case ToggleOption.savings:
      return context.l10n.navSavings;
    case ToggleOption.subscription:
      return context.l10n.subscriptions;
  }
}

Color _toggleOptionColor(ToggleOption option) {
  switch (option) {
    case ToggleOption.income:
      return AppColors.income;
    case ToggleOption.expense:
      return AppColors.expense;
    case ToggleOption.transfer:
      return AppColors.transfer;
    case ToggleOption.savings:
      return AppColors.savings;
    case ToggleOption.subscription:
      return AppColors.subscription;
  }
}

IconData _toggleOptionIcon(ToggleOption option, bool isSelected) {
  switch (option) {
    case ToggleOption.income:
      return isSelected
          ? PhosphorIconsBold.arrowUp
          : PhosphorIconsRegular.arrowUp;
    case ToggleOption.expense:
      return isSelected
          ? PhosphorIconsBold.arrowDown
          : PhosphorIconsRegular.arrowDown;
    case ToggleOption.transfer:
      return isSelected
          ? PhosphorIconsBold.arrowsLeftRight
          : PhosphorIconsRegular.arrowsLeftRight;
    case ToggleOption.savings:
      return isSelected
          ? PhosphorIconsBold.tipJar
          : PhosphorIconsRegular.tipJar;
    case ToggleOption.subscription:
      return isSelected
          ? PhosphorIconsBold.receipt
          : PhosphorIconsRegular.receipt;
  }
}

// ---------------------------------------------------------------------------
// Helper functions – TransactionType
// ---------------------------------------------------------------------------

String _transactionTypeLabel(BuildContext context, TransactionType option) {
  switch (option) {
    case TransactionType.income:
      return context.l10n.income;
    case TransactionType.expense:
      return context.l10n.expenses;
    case TransactionType.transfer:
      return context.l10n.transfer;
  }
}

Color _transactionTypeColor(TransactionType option) {
  switch (option) {
    case TransactionType.income:
      return AppColors.income;
    case TransactionType.expense:
      return AppColors.expense;
    case TransactionType.transfer:
      return AppColors.transfer;
  }
}

IconData _transactionTypeIcon(TransactionType option, bool isSelected) {
  switch (option) {
    case TransactionType.income:
      return isSelected
          ? PhosphorIconsBold.arrowUp
          : PhosphorIconsRegular.arrowUp;
    case TransactionType.expense:
      return isSelected
          ? PhosphorIconsBold.arrowDown
          : PhosphorIconsRegular.arrowDown;
    case TransactionType.transfer:
      return isSelected
          ? PhosphorIconsBold.arrowsLeftRight
          : PhosphorIconsRegular.arrowsLeftRight;
  }
}
