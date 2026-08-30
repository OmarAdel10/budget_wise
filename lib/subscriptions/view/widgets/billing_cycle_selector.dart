import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/custom_toggle_button.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:flutter/material.dart';

class BillingCycleSelector extends StatelessWidget {
  final ValueNotifier<BillingCycle> billingCycleNotifier;

  const BillingCycleSelector({super.key, required this.billingCycleNotifier});

  @override
  Widget build(BuildContext context) {
    //* Forth UI Idea (Best and recommendable)
    return ValueListenableBuilder(
      valueListenable: billingCycleNotifier,
      builder: (context, selectedCycle, child) {
        return Column(
          children: [
            Row(
              spacing: AppSpacing.sm,
              children: BillingCycle.values
                  .where((i) => i.index <= 1)
                  .map(
                    (cycle) => Expanded(
                      child: CustomToggleButton(
                        label: _getCycleLabel(cycle, context),
                        isSelected: selectedCycle == cycle,
                        onTap: () => billingCycleNotifier.value = cycle,
                        hasPadding: true,
                        hasBottomMargin: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
            Row(
              spacing: AppSpacing.sm,
              children: BillingCycle.values
                  .where((i) => i.index > 1 && i.index <= 3)
                  .map(
                    (cycle) => Expanded(
                      child: CustomToggleButton(
                        label: _getCycleLabel(cycle, context),
                        isSelected: selectedCycle == cycle,
                        onTap: () => billingCycleNotifier.value = cycle,
                        hasPadding: true,
                        hasBottomMargin: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
            Row(
              children: BillingCycle.values
                  .where((i) => i.index == BillingCycle.values.length - 1)
                  .map(
                    (cycle) => Expanded(
                      child: CustomToggleButton(
                        label: _getCycleLabel(cycle, context),
                        isSelected: selectedCycle == cycle,
                        onTap: () => billingCycleNotifier.value = cycle,
                        hasPadding: true,
                        hasBottomMargin: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );

    //* Third UI Idea (Better and recommendable)
    // return ValueListenableBuilder(
    //   valueListenable: billingCycleNotifier,
    //   builder: (context, selectedCycle, child) {
    //     return Column(
    //       children: BillingCycle.values
    //           .map(
    //             (cycle) => CustomToggleButton(
    //               label: _getCycleLabel(cycle, context.l10n),
    //               isSelected: selectedCycle == cycle,
    //               onTap: () => billingCycleNotifier.value = cycle,
    //               hasPadding: true,
    //               hasBottomMargin: true,
    //             ),
    //           )
    //           .toList(),
    //     );
    //   },
    // );

    //! Second UI Idea (not recommended)
    // return Container(
    //   padding: const EdgeInsets.all(4),
    //   decoration: BoxDecoration(
    //     color: AppColors.inputBackground,
    //     borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    //     border: Border.all(color: AppColors.borderColor),
    //   ),
    //   child: ValueListenableBuilder<BillingCycle>(
    //     valueListenable: billingCycleNotifier,
    //     builder: (context, selectedCycle, _) {
    //       return GridView.builder(
    //         padding: EdgeInsets.zero,
    //         shrinkWrap: true,
    //         addRepaintBoundaries: true,
    //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 2,
    //           childAspectRatio: 5,
    //           mainAxisSpacing: AppSpacing.sm,
    //           crossAxisSpacing: AppSpacing.sm,
    //         ),
    //         itemCount: BillingCycle.values.length,
    //         physics: const NeverScrollableScrollPhysics(),
    //         itemBuilder: (context, index) {
    //           final cycle = BillingCycle.values[index];
    //           return CustomToggleButton(
    //             label: _getCycleLabel(cycle, context.l10n),
    //             isSelected: selectedCycle == cycle,
    //             onTap: () => billingCycleNotifier.value = cycle,
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );

    //! First UI Idea (Midium recommmendation)
    // return Container(
    //   padding: const EdgeInsets.all(4),
    //   decoration: BoxDecoration(
    //     color: AppColors.inputBackground,
    //     borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    //     border: Border.all(color: AppColors.borderColor),
    //   ),
    //   child: ValueListenableBuilder<BillingCycle>(
    //     valueListenable: billingCycleNotifier,
    //     builder: (context, selectedCycle, _) {
    //       return Wrap(
    //         spacing: 6,
    //         runSpacing: 6,
    //         children: BillingCycle.values.map((cycle) {
    //           return SizedBox(
    //             width:
    //                 double.infinity,
    //             height: 40,
    //             child: CustomToggleButton(
    //               label: _getCycleLabel(cycle, context.l10n),
    //               isSelected: selectedCycle == cycle,
    //               onTap: () => billingCycleNotifier.value = cycle,
    //             ),
    //           );
    //         }).toList(),
    //       );
    //     },
    //   ),
    // );
  }

  String _getCycleLabel(BillingCycle cycle, BuildContext context) {
    switch (cycle) {
      case BillingCycle.weekly:
        return context.l10n.weekly;
      case BillingCycle.monthly:
        return context.l10n.monthly;
      case BillingCycle.quarterly:
        return context.l10n.quarterly;
      case BillingCycle.halfYearly:
        return context.l10n.halfYearly;
      case BillingCycle.yearly:
        return context.l10n.yearly;
    }
  }
}
