import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../widgets/transaction_amount_header.dart';
import '../widgets/transaction_info_card.dart';
import '../widgets/transaction_action_buttons.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const String routeName = '/transaction-detail';
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final transModel = args?['transModel'] as TransactionModel;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) {
        final prevTrans = previous.transactionsList
            .where((t) => t.id == transModel.id)
            .firstOrNull;
        final currTrans = current.transactionsList
            .where((t) => t.id == transModel.id)
            .firstOrNull;
        return prevTrans != currTrans;
      },
      builder: (context, state) {
        final transaction =
            state.transactionsList
                .where((t) => t.id == transModel.id)
                .firstOrNull ??
            transModel;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              transaction.type == TransactionType.income
                  ? l10n.incomeDetails
                  : l10n.expenseDetails,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TransactionAmountHeader(transaction: transaction),
                  const SizedBox(height: AppSpacing.xxl),
                  TransactionInfoCard(transaction: transaction),
                  const SizedBox(height: AppSpacing.xxl),
                  TransactionActionButtons(transaction: transaction),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
