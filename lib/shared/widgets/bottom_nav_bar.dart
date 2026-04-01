import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                      ? PhosphorIcons.house(PhosphorIconsStyle.fill)
                      : PhosphorIcons.house(),
                ),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 1
                      ? PhosphorIcons.wallet(PhosphorIconsStyle.fill)
                      : PhosphorIcons.wallet(),
                ),
                label: l10n.navAccounts,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 2
                      ? PhosphorIcons.repeat(PhosphorIconsStyle.fill)
                      : PhosphorIcons.repeat(),
                ),
                label: l10n.subscriptions,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 3
                      ? PhosphorIcons.piggyBank(PhosphorIconsStyle.fill)
                      : PhosphorIcons.piggyBank(),
                ),
                label: l10n.navSavings,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 4
                      ? PhosphorIcons.chartLine(PhosphorIconsStyle.fill)
                      : PhosphorIcons.chartLine(),
                ),
                label: l10n.navStatistics,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  currentIndex == 5
                      ? PhosphorIcons.gear(PhosphorIconsStyle.fill)
                      : PhosphorIcons.gear(),
                ),
                label: l10n.navSettings,
              ),
            ],
          );
        },
      ),
    );
  }
}
