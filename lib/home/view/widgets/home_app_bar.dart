import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';

import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.appTitle,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            final pendingSmsCount =
                transactionState.pendingSmsTransactions.length;
            return Row(
              children: [
                if (pendingSmsCount == 0) ...[
                  IconButton(
                    icon: Icon(
                      PhosphorIcons.bellSimple(PhosphorIconsStyle.bold),
                    ),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(PendingSmsTransactionsScreen.routeName);
                    },
                  ),
                ],
                if (pendingSmsCount > 0) ...[
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.bellSimple(PhosphorIconsStyle.bold),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(PendingSmsTransactionsScreen.routeName);
                        },
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$pendingSmsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
