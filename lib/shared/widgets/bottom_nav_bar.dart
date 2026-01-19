import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(widget.currentIndex == 0 ? PhosphorIcons.house(PhosphorIconsStyle.fill) : PhosphorIcons.house()),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.currentIndex == 1 ? PhosphorIcons.wallet(PhosphorIconsStyle.fill) : PhosphorIcons.wallet()),
            label: l10n.navAccounts,
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.currentIndex == 2 ? PhosphorIcons.piggyBank(PhosphorIconsStyle.fill) : PhosphorIcons.piggyBank()),
            label: l10n.navSavings,
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.currentIndex == 3 ? PhosphorIcons.chartLine(PhosphorIconsStyle.fill) : PhosphorIcons.chartLine()),
            label: l10n.navStatistics,
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.currentIndex == 4 ? PhosphorIcons.gear(PhosphorIconsStyle.fill) : PhosphorIcons.gear()),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
