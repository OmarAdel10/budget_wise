import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/empty_state.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/view/widgets/pending_sms_list_view.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingSmsBottomSheet extends StatefulWidget {
  const PendingSmsBottomSheet({super.key});

  @override
  State<PendingSmsBottomSheet> createState() => _PendingSmsBottomSheetState();
}

class _PendingSmsBottomSheetState extends State<PendingSmsBottomSheet> {
  final GlobalKey<NavigatorState> _navStateKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Navigator(
            key: _navStateKey,
            onGenerateRoute: (settings) => BottomSheetService.pageRoute(
              child: (context) =>
                  _PendingSmsListContent(scrollController: scrollController),
            ),
          ),
        );
      },
    );
  }
}

class _PendingSmsListContent extends StatelessWidget {
  final ScrollController scrollController;

  const _PendingSmsListContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetService.header(
              title: context.l10n.pendingSmsTransactionsTitle,
              isRoot: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child:
                  BlocSelector<
                    TransactionBloc,
                    TransactionState,
                    List<SmsDraftModel>
                  >(
                    selector: (state) => state.pendingSmsTransactions,
                    builder: (context, pendingDrafts) {
                      if (pendingDrafts.isEmpty) {
                        return EmptyState(
                          text: context.l10n.noPendingSmsTransactions,
                        );
                      }

                      return PendingSmsListView(pendingDrafts: pendingDrafts);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
