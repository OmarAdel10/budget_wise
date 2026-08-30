import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:table_calendar/table_calendar.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class DatePickerField extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDate;
  final Color activeColor;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? label;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.activeColor,
    this.firstDate,
    this.lastDate,
    this.label,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final ValueNotifier<bool> _isOpen = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showBelow = ValueNotifier<bool>(true);

  void _toggleOverlay() {
    if (_isOpen.value) {
      _closeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final pos = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    const overlayHeight = 400.0; // or get from a GlobalKey on the content
    final spaceBelow = screenSize.height - pos.dy - renderBox.size.height;
    _showBelow.value = spaceBelow >= overlayHeight;
    _overlayEntry = _createOverlayEntry(showBelow: _showBelow);
    overlay.insert(_overlayEntry!);
    _isOpen.value = true;
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen.value = false;
  }

  OverlayEntry _createOverlayEntry({required ValueNotifier<bool> showBelow}) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeOverlay,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: showBelow,
            builder: (context, showBelow, child) {
              return CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                followerAnchor: showBelow
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                targetAnchor: showBelow
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                offset: showBelow ? const Offset(0, -10) : const Offset(0, 40),
                child: Material(
                  color: Colors.transparent,
                  child: _FloatingDatePickerContent(
                    initialDate: widget.selectedDate.value,
                    firstDate: widget.firstDate ?? DateTime(2020),
                    lastDate:
                        widget.lastDate ??
                        DateTime.now().add(const Duration(days: 365 * 10)),
                    onDateSelected: (date) {
                      widget.selectedDate.value = date;
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _isOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
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
          GestureDetector(
            onTap: _toggleOverlay,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isOpen,
              builder: (context, isOpen, _) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.2,
                    ),
                    boxShadow: [AppBoxShadow()],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsRegular.calendarDots,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        context.l10n.pickDate,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ValueListenableBuilder<DateTime>(
                          valueListenable: widget.selectedDate,
                          builder: (context, date, _) {
                            return AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInCubic,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isOpen
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isOpen
                                    ? AppColors.primaryAccent
                                    : AppColors.textPrimary,
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(date),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AnimatedRotation(
                        turns: isOpen ? 0.25 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          PhosphorIconsBold.caretRight,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDatePickerContent extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const _FloatingDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<_FloatingDatePickerContent> createState() =>
      _FloatingDatePickerContentState();
}

class _FloatingDatePickerContentState extends State<_FloatingDatePickerContent>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<DateTime> _focusedDay;
  late final ValueNotifier<DateTime> _selectedDay;
  late final ValueNotifier<bool> _isMonthYearView;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  final DateTime _today = DateTime.now();
  late final DateTime _minSelectableDate;

  final List<int> _years = List.generate(
    81,
    (index) => 2020 + index,
  ); // 2020 to 2100

  @override
  void initState() {
    super.initState();
    _minSelectableDate = DateTime(_today.year - 1, _today.month, _today.day);

    _selectedDay = ValueNotifier<DateTime>(widget.initialDate);
    _focusedDay = ValueNotifier<DateTime>(widget.initialDate);
    _isMonthYearView = ValueNotifier<bool>(false);

    _monthController = FixedExtentScrollController(
      initialItem: widget.initialDate.month - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(widget.initialDate.year),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectedDay.dispose();
    _focusedDay.dispose();
    _isMonthYearView.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _toggleView() {
    _isMonthYearView.value = !_isMonthYearView.value;
  }

  void _updateFocusedDate({int? month, int? year}) {
    final current = _focusedDay.value;
    int targetMonth = month ?? current.month;
    int targetYear = year ?? current.year;

    // 1. Check Year Boundaries (Only Current and Past year allowed)
    if (targetYear > _today.year) {
      _yearController.animateToItem(
        _years.indexOf(_today.year),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    } else if (targetYear < _today.year - 1) {
      _yearController.animateToItem(
        _years.indexOf(_today.year - 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    // 2. Check Month Boundaries for Current Year (can't be future)
    if (targetYear == _today.year && targetMonth > _today.month) {
      _monthController.animateToItem(
        _today.month - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    // 3. Check Month Boundaries for Past Year (can't be before exactly 1yr limit)
    if (targetYear == _today.year - 1 && targetMonth < _today.month) {
      _monthController.animateToItem(
        _today.month - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    _focusedDay.value = DateTime(targetYear, targetMonth);
  }

  bool _isDateEnabled(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedMin = DateTime(
      _minSelectableDate.year,
      _minSelectableDate.month,
      _minSelectableDate.day,
    );
    final normalizedToday = DateTime(_today.year, _today.month, _today.day);

    return normalizedDate.isAfter(
          normalizedMin.subtract(const Duration(days: 1)),
        ) &&
        normalizedDate.isBefore(normalizedToday.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 300,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildPillHeader(),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isMonthYearView,
                      builder: (context, isMonthYear, _) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isMonthYear
                              ? _buildMonthYearPicker()
                              : _buildCalendarView(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillHeader() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isMonthYearView,
      builder: (context, isMonthYear, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleNavButton(
                icon: PhosphorIconsBold.caretLeft,
                onPressed: () {
                  final current = _focusedDay.value;
                  if (isMonthYear) {
                    _updateFocusedDate(year: current.year - 1);
                  } else {
                    _updateFocusedDate(month: current.month - 1);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: _toggleView,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isMonthYear
                        ? AppColors.primaryAccent.withValues(alpha: 0.15)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isMonthYear
                          ? AppColors.primaryAccent
                          : AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _focusedDay,
                    builder: (context, focusedDay, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isMonthYear
                                ? focusedDay.year.toString()
                                : DateFormat.yMMMM().format(focusedDay),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isMonthYear
                                  ? AppColors.primaryAccent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: isMonthYear ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              PhosphorIconsRegular.caretDown,
                              color: isMonthYear
                                  ? AppColors.primaryAccent
                                  : AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildCircleNavButton(
                icon: PhosphorIconsBold.caretRight,
                onPressed: () {
                  final current = _focusedDay.value;
                  if (isMonthYear) {
                    _updateFocusedDate(year: current.year + 1);
                  } else {
                    _updateFocusedDate(month: current.month + 1);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildCalendarView() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _focusedDay,
      builder: (context, focusedDay, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: _selectedDay,
          builder: (context, selectedDay, _) {
            return TableCalendar(
              key: const ValueKey('calendar'),
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              focusedDay: focusedDay,
              headerVisible: false,
              enabledDayPredicate: _isDateEnabled,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (newSelectedDay, newFocusedDay) {
                if (_isDateEnabled(newSelectedDay)) {
                  _selectedDay.value = newSelectedDay;
                  _focusedDay.value = newFocusedDay;
                  widget.onDateSelected(newSelectedDay);
                }
              },
              onPageChanged: (newFocusedDay) {
                _focusedDay.value = newFocusedDay;
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                weekendTextStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                disabledTextStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthYearPicker() {
    return SizedBox(
      key: const ValueKey('wheelPicker'),
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: _monthController,
              itemExtent: 40,
              onSelectedItemChanged: (index) async {
                await Future.delayed(const Duration(milliseconds: 800));
                _updateFocusedDate(month: index + 1);
              },
              children: List.generate(12, (index) {
                final month = index + 1;
                bool isEnabled = true;

                if (_focusedDay.value.year == _today.year &&
                    month > _today.month) {
                  isEnabled = false;
                } else if (_focusedDay.value.year == _today.year - 1 &&
                    month < _today.month) {
                  isEnabled = false;
                }

                return Center(
                  child: Text(
                    _monthNames[index].toUpperCase(),
                    style: AppTextStyles.heading3.copyWith(
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                      fontWeight: isEnabled ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: _yearController,
              itemExtent: 40,
              onSelectedItemChanged: (index) async {
                await Future.delayed(const Duration(milliseconds: 800));
                _updateFocusedDate(year: _years[index]);
              },
              children: _years.map((year) {
                bool isEnabled =
                    (year == _today.year || year == _today.year - 1);
                return Center(
                  child: Text(
                    year.toString(),
                    style: AppTextStyles.heading3.copyWith(
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                      fontWeight: isEnabled ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
