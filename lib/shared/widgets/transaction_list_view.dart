import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/widgets/empty_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/spacing.dart';

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;
  final EdgeInsets? padding;
  final Widget? emptyState;
  final bool _isSliver;
  final bool hasBackgroundColor;
  final Widget? prototypeItem;
  final bool hasBottomSpace;
  final bool? isRoot;

  const TransactionListView({
    super.key,
    required this.transactions,
    this.padding,
    this.emptyState,
    this.hasBackgroundColor = true,
    this.prototypeItem,
    this.hasBottomSpace = false,
    this.isRoot,
  }) : _isSliver = false;

  const TransactionListView.sliver({
    super.key,
    required this.transactions,
    this.emptyState,
    this.hasBackgroundColor = true,
    this.prototypeItem,
    this.hasBottomSpace = false,
    this.isRoot,
  }) : padding = null,
       _isSliver = true;

  @override
  Widget build(BuildContext context) {
    final transBloc = context.read<TransactionBloc>();

    if (transactions.isEmpty) {
      final emptyWidget =
          emptyState ?? EmptyState(text: context.l10n.noTransactionsFound);
      return _isSliver ? SliverToBoxAdapter(child: emptyWidget) : emptyWidget;
    }

    if (_isSliver) {
      final delegate = SliverChildBuilderDelegate(
        (context, index) => TransactionListItem(
          model: transactions[index],
          isRoot: isRoot,
          hasBG: hasBackgroundColor,
          onDelete: () {
            AppToast.show(
              context,
              type: AppToastType.success,
              title: context.l10n.transactionDeletedSuccessfully,
            );
            transBloc.add(
              TransactionEventDeleteTransaction(
                transactionId: transactions[index].id,
              ),
            );
          },
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
        final isLast = index == transactions.length - 1;
        return Column(
          children: [
            TransactionListItem(
              model: transactions[index],
              isRoot: isRoot,
              hasBG: hasBackgroundColor,
              onDelete: () {
                AppToast.show(
                  context,
                  type: AppToastType.success,
                  title: context.l10n.transactionDeletedSuccessfully,
                );
                transBloc.add(
                  TransactionEventDeleteTransaction(
                    transactionId: transactions[index].id,
                  ),
                );
              },
            ),

            if (hasBottomSpace && isLast)
              const SizedBox(height: AppSpacing.xxxl + 4),
          ],
        );
      },
    );
  }
}
