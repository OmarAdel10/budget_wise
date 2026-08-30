import 'package:budget_wise/accounts/view/widgets/asset_item.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/bottom_sheets/accounts_bottom_sheet.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeTopSheet extends StatelessWidget {
  final Function(String, double, IconData) ontap;
  const HomeTopSheet({super.key, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.selectAccount,
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(PhosphorIconsBold.gearFine, size: 20),
                onPressed: () async {
                  final currentContext = context;
                  Navigator.pop(currentContext);
                  await Future.delayed(const Duration(milliseconds: 150));
                  if (!currentContext.mounted) return;
                  showModalBottomSheet(
                    context: currentContext,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const AccountsBottomSheet(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // All Accounts Item
                    GestureDetector(
                      onTap: () {
                        context.read<HomeBloc>().add(
                          const HomeEventChangeAccountFilter(null),
                        );
                        ontap(
                          context.l10n.allAccounts,
                          accountState.netWorth,
                          PhosphorIconsBold.wallet,
                        );
                        Navigator.pop(context);
                      },
                      child: AssetItem.selectable(
                        icon: PhosphorIconsBold.wallet,
                        title: context.l10n.allAccounts,
                        amount: '${accountState.netWorth}',
                        isSelected:
                            context
                                .watch<HomeBloc>()
                                .state
                                .model
                                .filterAccountId ==
                            null,
                      ),
                    ),
                    ...accountState.accountsList.map((account) {
                      return GestureDetector(
                        onTap: () {
                          context.read<HomeBloc>().add(
                            HomeEventChangeAccountFilter(account.id),
                          );
                          ontap(
                            account.title,
                            account.balance,
                            account.accountIcon,
                          );
                          Navigator.pop(context);
                        },
                        child: AssetItem.selectable(
                          icon: account.accountIcon,
                          title: account.title,
                          amount: '${account.balance}',
                          isSelected:
                              context
                                  .watch<HomeBloc>()
                                  .state
                                  .model
                                  .filterAccountId ==
                              account.id,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
