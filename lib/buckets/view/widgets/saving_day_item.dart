import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/buckets/view_model/buckets_event.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SavingDayItem extends StatelessWidget {
  final SavingGoalModel goal;
  final int dayNum;
  final double amount;
  final bool isCompleted;

  const SavingDayItem({
    super.key,
    required this.goal,
    required this.dayNum,
    required this.amount,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (goal.method == SavingGoalMethod.custom) {
          _showCustomAmountSheet(context, goal, dayNum);
        } else {
          context.read<BucketsBloc>().add(
            BucketsEventToggleDayContribution(goalId: goal.id, day: dayNum),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isCompleted
              ? Border.all(color: Color(goal.colorValue).withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isCompleted
                      ? Color(goal.colorValue)
                      : AppColors.primaryBackground,
                  child: Text(
                    "$dayNum",
                    style: TextStyle(
                      color: isCompleted ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(context.l10n.dayCount(dayNum), style: AppTextStyles.bodyLarge),
              ],
            ),
            Row(
              children: [
                if (goal.method == SavingGoalMethod.custom && amount == 0)
                  Text(
                    context.l10n.tapToChangeIcon, // Reusing existing key or we could add "tapToSet"
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    "${goal.currency} ${amount.toInt()}",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  isCompleted
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsRegular.circle,
                  color: isCompleted
                      ? Color(goal.colorValue)
                      : AppColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAmountSheet(
    BuildContext context,
    SavingGoalModel goal,
    int day,
  ) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cardBackground,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.setAmountForDay(day), style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: context.l10n.enterAmount,
              controller: controller,
              keyboardType: TextInputType.number,
              suffixIcon: CloseButton(onPressed: controller.clear),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: context.l10n.saveContribution,
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0;
                if (val > 0) {
                  context.read<BucketsBloc>().add(
                    BucketsEventUpdateCustomAmount(
                      goalId: goal.id,
                      day: day,
                      amount: val,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
