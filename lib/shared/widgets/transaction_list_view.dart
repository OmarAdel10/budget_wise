import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;
  final EdgeInsets? padding;
  final Widget? emptyState;
  final bool _isSliver;
  final bool hasBackgroundColor;
  final Widget? prototypeItem;

  const TransactionListView({
    super.key,
    required this.transactions,
    this.padding,
    this.emptyState,
    this.hasBackgroundColor = true,
    this.prototypeItem,
  }) : _isSliver = false;

  const TransactionListView.sliver({
    super.key,
    required this.transactions,
    this.emptyState,
    this.hasBackgroundColor = true,
    this.prototypeItem,
  }) : padding = null,
       _isSliver = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transBloc = context.read<TransactionBloc>();

    if (transactions.isEmpty) {
      final emptyWidget =
          emptyState ??
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Text(
                l10n.noTransactionsFound,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
      return _isSliver ? SliverToBoxAdapter(child: emptyWidget) : emptyWidget;
    }

    if (_isSliver) {
      final delegate = SliverChildBuilderDelegate(
        (context, index) => TransactionListItem(
          model: transactions[index],
          hasBG: hasBackgroundColor,
          onDelete: () => transBloc.add(
            TransactionEventDeleteTransaction(
              transactionId: transactions[index].id,
            ),
          ),
        ),
        childCount: transactions.length,
      );

      if (prototypeItem != null) {
        return SliverPrototypeExtentList(
          prototypeItem: prototypeItem!,
          delegate: delegate,
        );
      }
      return SliverList(delegate: delegate);
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: transactions.length,
      prototypeItem: prototypeItem,
      itemBuilder: (context, index) {
        return TransactionListItem(
          model: transactions[index],
          hasBG: hasBackgroundColor,
          onDelete: () => transBloc.add(
            TransactionEventDeleteTransaction(
              transactionId: transactions[index].id,
            ),
          ),
        );
      },
    );
  }
}
