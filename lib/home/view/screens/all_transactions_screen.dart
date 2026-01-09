import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/home/view/widgets/transaction_list_item.dart';

class AllTransactionsScreen extends StatefulWidget {
  static const String routeName = '/all-transactions';
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    final homeState = context.read<HomeBloc>().state;
    selectedMonth = homeState.model.currentMonth;
  }

  void _monthChange(int month) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + month);
    });
    context.read<HomeBloc>().add(HomeEventLoadAllData(selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final transactions = state.model.transactions;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n.transactionHistory,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              //! Month Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _monthChange(-1),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat("MMMM yyyy").format(selectedMonth),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _monthChange(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              //! Summary Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.income}: ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${state.model.totalIncome.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '|',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${l10n.expenses}: ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${state.model.totalExpenses.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              //! Transaction List
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          "No transactions found",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          return TransactionListItem(model: transactions[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
