import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/widgets/transaction_list_item.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionTypeDetailScreen extends StatelessWidget {
  static const String routeName = '/transaction-type-detail';

  const TransactionTypeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final model = state.model;
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final type = args['type'];
        final l10n = AppLocalizations.of(context)!;
        final transactionsList = model.transactions
            .where(
              (trans) =>
                  trans.type ==
                  (type == 'income'
                      ? TransactionType.income
                      : TransactionType.expense),
            )
            .toList();
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
              type == 'income' ? l10n.incomeDetails : l10n.expenseDetails,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${l10n.total} ${type == 'income' ? l10n.income : l10n.expenses} ${DateFormat('MMMM yyyy').format(model.currentMonth)}",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "\$${type == 'income' ? model.totalIncome : model.totalExpenses}",
                          style: AppTextStyles.heading1.copyWith(
                            color: type == 'income'
                                ? AppColors.primaryAccent
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(l10n.transactionHistory, style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.md),

                  // List
                  transactionsList.isNotEmpty
                      ? Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemCount: transactionsList.length,
                            itemBuilder: (context, index) {
                              final item = transactionsList[index];
                              return TransactionListItem(model: item);
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Lottie.asset(
                                'assets/lottie/no_data.json',
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
