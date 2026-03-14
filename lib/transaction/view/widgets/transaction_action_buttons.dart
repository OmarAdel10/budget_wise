import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/models/transaction_model.dart';
import '../../view_model/transaction_event.dart';
import '../../view_model/transaction_view_model.dart';
import '../screens/add_transaction_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/colors.dart';
import '../../../../shared/constants/spacing.dart';
import '../../../../shared/utils/app_toast.dart';

class TransactionActionButtons extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionActionButtons({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddTransactionScreen(transactionToEdit: transaction),
                ),
              );
            },
            icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
            label: Text(l10n.edit),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.textSecondary),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final transBloc = context.read<TransactionBloc>();

              AppToast.show(
                context,
                type: AppToastType.deleteWithUndo,
                title: l10n.transactionDeleted,
                onCompleted: () {
                  transBloc.add(
                    TransactionEventDeleteTransaction(
                      transactionId: transaction.id,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              );
            },
            icon: Icon(PhosphorIcons.trash(), size: 20),
            label: Text(l10n.delete),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
