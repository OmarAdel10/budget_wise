import 'package:flutter/material.dart';
import '../../data/models/savings_model.dart';
import 'saving_day_item.dart';
import '../../../shared/constants/dimensions.dart';

class SavingDaysSliverList extends StatelessWidget {
  final SavingsModel goal;
  final List<int> days;
  final bool isCompleted;

  const SavingDaysSliverList({
    super.key,
    required this.goal,
    required this.days,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverFixedExtentList(
      itemExtent: AppDimensions.savingDayItemTotalExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dayNum = days[index];
          final amount = goal.getAmountForDay(dayNum);

          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.savingDayItemGap),
            child: SavingDayItem(
              goal: goal,
              dayNum: dayNum,
              amount: amount,
              isCompleted: isCompleted,
            ),
          );
        },
        childCount: days.length,
      ),
    );
  }
}
