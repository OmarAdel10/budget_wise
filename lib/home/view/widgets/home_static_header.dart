import 'package:budget_wise/home/view/widgets/home_top_sheet.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/home/view/widgets/home_summary_row.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeStaticHeader extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final String currencySymbol;

  const HomeStaticHeader({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          HomeSummaryRow(
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            currencySymbol: currencySymbol,
            isCollapsed: false,
          ),
          const SizedBox(height: AppSpacing.md),
          _AllAccountsCard(currencySymbol: currencySymbol),
        ],
      ),
    );
  }
}

class _AllAccountsCard extends StatefulWidget {
  final String currencySymbol;

  const _AllAccountsCard({required this.currencySymbol});

  @override
  State<_AllAccountsCard> createState() => _AllAccountsCardState();
}

class _AllAccountsCardState extends State<_AllAccountsCard> {
  late ValueNotifier<String> titleNotifier;
  late ValueNotifier<double> amountNotifier;
  late ValueNotifier<IconData> iconNotifier;

  @override
  void initState() {
    super.initState();
    titleNotifier = ValueNotifier('');
    amountNotifier = ValueNotifier(0.0);
    iconNotifier = ValueNotifier(PhosphorIconsBold.wallet);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final allAccountsAmount = context.read<AccountBloc>().state.netWorth;
    titleNotifier.value = context.l10n.allAccounts;
    amountNotifier.value = allAccountsAmount;
  }

  void onAccountSelectTap(
    String selectedTitle,
    double selectedAmount,
    IconData selectedIcon,
  ) {
    titleNotifier.value = selectedTitle;
    amountNotifier.value = selectedAmount;
    iconNotifier.value = selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) =>
          previous.accountsList != current.accountsList &&
          previous.netWorth != current.netWorth,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Dismiss Top Sheet',
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, _, _) {
                return SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: HomeTopSheet(ontap: onAccountSelectTap),
                    ),
                  ),
                );
              },
              transitionBuilder: (context, anim1, anim2, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(0, -1), end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: anim1,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [AppBoxShadow()]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ValueListenableBuilder<IconData>(
                  valueListenable: iconNotifier,
                  builder: (context, value, child) {
                    return GenericIconContainer(
                      icon: value,
                      color: AppColors.textSecondary,
                      backgroundOpacity: 0,
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.md),
                ValueListenableBuilder<String>(
                  valueListenable: titleNotifier,
                  builder: (context, value, child) {
                    return Text(value, style: AppTextStyles.bodyLarge);
                  },
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.balance, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    ValueListenableBuilder<double>(
                      valueListenable: amountNotifier,
                      builder: (context, value, child) {
                        return Text(
                          '${widget.currencySymbol} ${value.toStringAsFixed(0)}',
                          style: AppTextStyles.heading3.copyWith(
                            color: state.netWorth.isNegative
                                ? AppColors.expense
                                : AppColors.income,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  PhosphorIconsFill.caretDown,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
