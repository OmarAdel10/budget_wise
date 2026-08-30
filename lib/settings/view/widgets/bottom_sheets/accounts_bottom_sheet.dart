import 'package:budget_wise/accounts/view/screens/add_account_bottom_sheet.dart';
import 'package:budget_wise/accounts/view/widgets/net_worth_section.dart';
import 'package:budget_wise/accounts/view/widgets/accounts_list.dart';
import 'package:budget_wise/accounts/view/widgets/link_more_accounts_button.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountsBottomSheet extends StatefulWidget {
  const AccountsBottomSheet({super.key});

  @override
  State<AccountsBottomSheet> createState() => _AccountsBottomSheetState();
}

class _AccountsBottomSheetState extends State<AccountsBottomSheet> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.only(top: AppSpacing.md),
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
            child: (context) =>
                _AccountsBottomSheetContent(scrollController: scrollController),
          ),
        ),
      ),
    );
  }
}

class _AccountsBottomSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  const _AccountsBottomSheetContent({required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: BottomSheetService.header(
              title: context.l10n.navAccounts,
              isRoot: true,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    BottomSheetService.pageRoute(
                      child: (context) => AddAccountBottomSheet(
                        scrollController: scrollController,
                      ),
                    ),
                  ),
                  // onPressed: () => showModalBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.transparent,
                  //   isScrollControlled: true,
                  //   enableDrag: false,
                  //   useSafeArea: true,
                  //   // isDismissible: false,
                  //   builder: (context) => DraggableScrollableSheet(
                  //     shouldCloseOnMinExtent: false,

                  //     initialChildSize: 0.6,
                  //     maxChildSize: 0.9,
                  //     minChildSize: 0.2,
                  //     snap: true,
                  //     builder: (context, scrollController) =>
                  //         AddAccountBottomSheet(
                  //           scrollController: scrollController,
                  //         ),
                  //   ),
                  // ),
                  icon: const Icon(
                    PhosphorIconsBold.plus,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const NetWorthSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //* Accounts List
                Text(
                  context.l10n.yourAssets,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                const AccountsList(),
                const SliverToBoxAdapter(
                  child: Divider(
                    color: AppColors.borderColor,
                    indent: 50,
                    endIndent: 50,
                  ),
                ),
                const LinkMoreAccountsButton(),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
