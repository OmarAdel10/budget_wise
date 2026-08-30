import 'package:budget_wise/settings/view/widgets/tiles/bank_margin_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/currency_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/language_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/month_start_day_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/week_start_day_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/recent_transactions_count_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/merchant_rules_tile.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/drag_handle.dart';
import 'package:flutter/material.dart';

class PreferencesBottomSheet extends StatefulWidget {
  const PreferencesBottomSheet({super.key});

  @override
  State<PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<PreferencesBottomSheet> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.66,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      snap: true,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Navigator(
          key: _navKey,
          onGenerateRoute: (settings) => BottomSheetService.pageRoute(
            child: (context) => Scaffold(
              body: Column(
                children: [
                  BottomSheetService.header(title: 'Preferences', isRoot: true),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate([
                            const LanguageSettingsTile(),
                            const CurrencySettingsTile(),
                            const BankMarginTile(),
                            const RecentTransactionsCountTile(),
                            MonthStartDayTile(
                              scrollController: scrollController,
                            ),
                            const WeekStartDayTile(),
                            const MerchantRulesTile(),
                            const SizedBox(height: AppSpacing.lg),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
