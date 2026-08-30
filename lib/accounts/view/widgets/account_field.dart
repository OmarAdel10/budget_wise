import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountField extends StatefulWidget {
  final ValueNotifier<String?> selectedAccountIdNotifier;
  final ValueNotifier<String> titleNotifier;
  final ValueNotifier<IconData> iconNotifier;
  final ValueNotifier<bool> isSelectedNotifier;

  const AccountField({
    super.key,
    required this.selectedAccountIdNotifier,
    required this.titleNotifier,
    required this.iconNotifier,
    required this.isSelectedNotifier,
  });

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField> {
  void _onAccountChange(
    IconData selectedIcon,
    String selectedTitle,
    bool isSelected,
    String? selectedAccountId,
  ) {
    widget.titleNotifier.value = selectedTitle;
    widget.iconNotifier.value = selectedIcon;
    widget.isSelectedNotifier.value = isSelected;
    widget.selectedAccountIdNotifier.value = selectedAccountId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.accountLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            BottomSheetService.pageRoute(
              child: (context) {
                final scrollController = PrimaryScrollController.of(context);
                return AccountSelectionScreen(
                  onAccountSelect: _onAccountChange,
                  scrollController: scrollController,
                );
              },
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.all(
                Radius.circular(AppSpacing.radiusMd),
              ),
              border: Border.all(color: AppColors.borderColor, width: 0.2),
              boxShadow: [AppBoxShadow()],
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: ValueListenableBuilder<IconData>(
                    valueListenable: widget.iconNotifier,
                    builder: (context, icon, child) {
                      return Icon(
                        icon,
                        color: AppColors.textSecondary,
                        size: 20,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                ValueListenableBuilder<String>(
                  valueListenable: widget.titleNotifier,
                  builder: (context, text, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: widget.isSelectedNotifier,
                      builder: (context, isSelected, child) {
                        return Text(
                          text,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        );
                      },
                    );
                  },
                ),
                const Spacer(),
                const Icon(
                  PhosphorIconsBold.caretRight,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountSelectionScreen extends StatefulWidget {
  final String? filteredAccountId;
  final ScrollController scrollController;
  final Function(
    IconData icon,
    String title,
    bool isSelected,
    String? accountId,
  )
  onAccountSelect;

  const AccountSelectionScreen({
    super.key,
    required this.onAccountSelect,
    required this.scrollController,
    this.filteredAccountId,
  });

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  final ValueNotifier<bool> isEmpty = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    List<AccountModel> accounts = context
        .read<AccountBloc>()
        .state
        .accountsList;
    if (widget.filteredAccountId != null) {
      if (widget.filteredAccountId!.isNotEmpty) {
        accounts = accounts
            .where((acc) => acc.id != widget.filteredAccountId)
            .toList();
      }
    }
    if (accounts.isEmpty) {
      isEmpty.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            // Title + Back Button
            SliverToBoxAdapter(
              child: BottomSheetService.header(title: context.l10n.account),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: isEmpty,
                builder: (context, empty, child) {
                  if (empty) {
                    return EmptyState(
                      text: 'There is no accounts available for selection',
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 0.4,
                      ),
                    ),
                    child:
                        BlocSelector<
                          AccountBloc,
                          AccountState,
                          List<AccountModel>
                        >(
                          selector: (state) => state.accountsList,
                          builder: (context, state) {
                            List<AccountModel> accounts = state;
                            if (widget.filteredAccountId != null) {
                              if (widget.filteredAccountId!.isNotEmpty) {
                                accounts = accounts
                                    .where(
                                      (acc) =>
                                          acc.id != widget.filteredAccountId,
                                    )
                                    .toList();
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              child: Column(
                                children: [
                                  ...accounts.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final acc = entry.value;
                                    final isLastItem =
                                        index == accounts.length - 1;
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            widget.onAccountSelect(
                                              acc.accountIcon,
                                              acc.title,
                                              true,
                                              acc.id,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: _AccountItem(
                                            accountName: acc.title,
                                            icon: acc.accountIcon,
                                          ),
                                        ),
                                        if (!isLastItem) ...[
                                          const Divider(
                                            color: AppColors.borderColor,
                                          ),
                                        ],
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String accountName;
  const _AccountItem({required this.icon, required this.accountName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.borderColor, width: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(accountName, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
