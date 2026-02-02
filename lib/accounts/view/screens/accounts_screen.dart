import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view/screens/add_account_screen.dart';
import 'package:budget_wise/accounts/view/widgets/asset_item.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:toastification/toastification.dart';

class AccountsScreen extends StatelessWidget {
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
                  //* Net Worth
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.netWorth,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '\$${state.netWorth}',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 34,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
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
          BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              if (state.accountsList.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final accountItem = state.accountsList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AccountDetailScreen.routeName,
                            arguments: accountItem,
                          );
                        },
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  final accountBloc = context
                                      .read<AccountBloc>();

                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.warning,
                                    style: ToastificationStyle.flatColored,
                                    autoCloseDuration: const Duration(
                                      seconds: 3,
                                    ),
                                    title: Text(l10n.accountDeleted),
                                    closeButton: ToastCloseButton(
                                      showType: CloseButtonShowType.always,
                                      buttonBuilder: (context, onClose) {
                                        return GestureDetector(
                                          onTap: onClose,
                                          child: Text(
                                            l10n.undo,
                                            style: AppTextStyles.button,
                                          ),
                                        );
                                      },
                                    ),
                                    callbacks: ToastificationCallbacks(
                                      onAutoCompleteCompleted: (item) {
                                        accountBloc.add(
                                          AccountEventDeleteAccount(
                                            accountId: accountItem.id,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                backgroundColor: AppColors.danger,
                                foregroundColor: Colors.white,
                                icon: PhosphorIcons.trash(
                                  PhosphorIconsStyle.bold,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                              ),
                            ],
                          ),
                          child: AssetItem(
                            icon: accountItem.accountIcon,
                            title: accountItem.title,
                            subtitle:
                                accountItem.accountType != AccountType.cash
                                ? '${accountItem.cardBankName} • ${accountItem.cardNumber != null && accountItem.cardNumber!.length >= 4 ? accountItem.cardNumber!.substring(accountItem.cardNumber!.length - 4) : '****'}'
                                : '${accountItem.accountType.name.toUpperCase()} ${l10n.account.toUpperCase()}',
                            amount:
                                '${NumberFormat.simpleCurrency(name: accountItem.currency).currencyName} ${accountItem.balance}',
                          ),
                        ),
                      ),
                    );
                  }, childCount: state.accountsList.length),
                ),
              );
            },
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AddAccountScreen.routeName);
                },
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(AppSpacing.radiusLg),
                    dashPattern: [10, 5],
                    strokeWidth: 2,
                    padding: EdgeInsets.all(16),
                    color: AppColors.borderColor.withValues(alpha: 0.6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.linkMoreAccounts,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}
