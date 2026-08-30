import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_field.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountsTransferCard extends StatefulWidget {
  final ValueNotifier<String?> fromAccountId;
  final ValueNotifier<String?> toAccountId;

  const AccountsTransferCard({
    super.key,
    required this.fromAccountId,
    required this.toAccountId,
  });

  @override
  State<AccountsTransferCard> createState() => _AccountsTransferCardState();
}

class _AccountsTransferCardState extends State<AccountsTransferCard> {
  late ValueNotifier<String> _fromAccountTitleNotifier;
  late ValueNotifier<IconData> _fromAccountIconNotifier;
  late ValueNotifier<bool> _isFromAccountSelectedNotifier;
  late ValueNotifier<String> _toAccountTitleNotifier;
  late ValueNotifier<IconData> _toAccountIconNotifier;
  late ValueNotifier<bool> _isToAccountSelectedNotifier;
  AccountModel? defaultAccount;

  @override
  void initState() {
    super.initState();
    if (widget.fromAccountId.value != null) {
      defaultAccount = context
          .read<AccountBloc>()
          .state
          .accountsList
          .where((acc) => acc.id == widget.fromAccountId.value)
          .firstOrNull;
      if (defaultAccount != null) {
        _fromAccountTitleNotifier = ValueNotifier<String>(
          defaultAccount!.title,
        );
        _fromAccountIconNotifier = ValueNotifier<IconData>(
          defaultAccount!.accountIcon,
        );
        _isFromAccountSelectedNotifier = ValueNotifier<bool>(true);
      }
    } else {
      _fromAccountTitleNotifier = ValueNotifier<String>('');
      _fromAccountIconNotifier = ValueNotifier<IconData>(
        PhosphorIconsRegular.bank,
      );
      _isFromAccountSelectedNotifier = ValueNotifier<bool>(false);
    }
    final toDefaultAccount = widget.toAccountId.value == null
        ? null
        : context
              .read<AccountBloc>()
              .state
              .accountsList
              .where((acc) => acc.id == widget.toAccountId.value)
              .firstOrNull;
    _toAccountTitleNotifier = ValueNotifier<String>(
      toDefaultAccount?.title ?? '',
    );
    _toAccountIconNotifier = ValueNotifier<IconData>(
      toDefaultAccount?.accountIcon ?? PhosphorIconsRegular.bank,
    );
    _isToAccountSelectedNotifier = ValueNotifier<bool>(
      toDefaultAccount != null,
    );
  }

  @override
  void dispose() {
    _fromAccountTitleNotifier.dispose();
    _fromAccountIconNotifier.dispose();
    _isFromAccountSelectedNotifier.dispose();
    _toAccountTitleNotifier.dispose();
    _toAccountIconNotifier.dispose();
    _isToAccountSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (defaultAccount == null && _fromAccountTitleNotifier.value.isEmpty) {
      _fromAccountTitleNotifier.value = context.l10n.selectAccount;
    }
    if (_toAccountTitleNotifier.value.isEmpty) {
      _toAccountTitleNotifier.value = context.l10n.selectAccount;
    }
  }

  void _onFromAccountChange(
    IconData selectedIcon,
    String selectedTitle,
    bool isSelected,
    String? selectedAccountId,
  ) {
    _fromAccountTitleNotifier.value = selectedTitle;
    _fromAccountIconNotifier.value = selectedIcon;
    _isFromAccountSelectedNotifier.value = isSelected;
    widget.fromAccountId.value = selectedAccountId;
  }

  void _onToAccountChange(
    IconData selectedIcon,
    String selectedTitle,
    bool isSelected,
    String? selectedAccountId,
  ) {
    _toAccountTitleNotifier.value = selectedTitle;
    _toAccountIconNotifier.value = selectedIcon;
    _isToAccountSelectedNotifier.value = isSelected;
    widget.toAccountId.value = selectedAccountId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 0.2),
        boxShadow: [AppBoxShadow()],
      ),
      child: Column(
        children: [
          // From Account
          _TransferAccountRow(
            label: context.l10n.fromAccount,
            iconNotifier: _fromAccountIconNotifier,
            accountNameNotifier: _fromAccountTitleNotifier,
            onTap: () => Navigator.of(context).push(
              BottomSheetService.pageRoute(
                child: (context) {
                  final scrollController = PrimaryScrollController.of(context);
                  return AccountSelectionScreen(
                    filteredAccountId: widget.toAccountId.value,
                    onAccountSelect: _onFromAccountChange,
                    scrollController: scrollController,
                  );
                },
              ),
            ),
          ),
          // Divider with Icon
          Stack(
            alignment: Alignment.center,
            children: [
              const Divider(color: AppColors.borderColor, height: 1),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: Icon(
                  PhosphorIconsRegular.arrowDown,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // To Account
          _TransferAccountRow(
            label: context.l10n.toAccount,
            iconNotifier: _toAccountIconNotifier,
            accountNameNotifier: _toAccountTitleNotifier,
            onTap: () => Navigator.of(context).push(
              BottomSheetService.pageRoute(
                child: (context) {
                  final scrollController = PrimaryScrollController.of(context);
                  return AccountSelectionScreen(
                    filteredAccountId: widget.fromAccountId.value,
                    onAccountSelect: _onToAccountChange,
                    scrollController: scrollController,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferAccountRow extends StatelessWidget {
  final String label;
  final ValueNotifier<IconData> iconNotifier;
  final ValueNotifier<String> accountNameNotifier;
  final VoidCallback onTap;

  const _TransferAccountRow({
    required this.label,
    required this.iconNotifier,
    required this.accountNameNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon
            ValueListenableBuilder<IconData>(
              valueListenable: iconNotifier,
              builder: (context, icon, child) {
                return Container(
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
                  child: Icon(icon, color: AppColors.textSecondary, size: 20),
                );
              },
            ),
            const SizedBox(width: AppSpacing.lg),
            // Name & Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: accountNameNotifier,
                    builder: (context, name, _) {
                      return Text(
                        name ?? context.l10n.selectAccount,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: name != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
