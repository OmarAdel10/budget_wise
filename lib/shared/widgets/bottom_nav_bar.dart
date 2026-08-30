import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomBottomNavBar extends StatelessWidget {
  final ValueNotifier<int> currentIndexNotifier;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndexNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: currentIndexNotifier,
        builder: (context, currentIndex, child) {
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.textPrimary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 0
                      ? PhosphorIconsFill.house
                      : PhosphorIconsRegular.house,
                ),
                label: context.l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 2
                      ? PhosphorIconsFill.repeat
                      : PhosphorIconsRegular.repeat,
                ),
                label: context.l10n.subscriptions,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 3
                      ? PhosphorIconsFill.piggyBank
                      : PhosphorIconsRegular.piggyBank,
                ),
                label: context.l10n.navSavings,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 4
                      ? PhosphorIconsFill.chartLine
                      : PhosphorIconsRegular.chartLine,
                ),
                label: context.l10n.navStatistics,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 5
                      ? PhosphorIconsFill.gear
                      : PhosphorIconsRegular.gear,
                ),
                label: context.l10n.navSettings,
              ),
            ],
          );
        },
      ),
    );
  }
}
