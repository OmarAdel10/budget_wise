import 'package:budget_wise/accounts/view/widgets/net_worth_section.dart';
import 'package:budget_wise/accounts/view/widgets/accounts_list.dart';
import 'package:budget_wise/accounts/view/widgets/link_more_accounts_button.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class AccountsScreen extends StatelessWidget {
  static const String routeName = '/accounts-screen';
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.navAccounts,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NetWorthSection(),
                  const SizedBox(height: AppSpacing.lg),
                  //* Accounts List
                  Text(
                    l10n.yourAssets,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AccountsList(),
          const SliverToBoxAdapter(
            child: Divider(
              color: AppColors.borderColor,
              indent: 50,
              endIndent: 50,
            ),
          ),
          const LinkMoreAccountsButton(),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}
