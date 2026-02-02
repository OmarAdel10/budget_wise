import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/view/screens/edit_account_screen.dart';
import 'package:budget_wise/accounts/view/widgets/credit_card_preview.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/home/view/screens/transaction_detail_screen.dart';
import 'package:budget_wise/home/view_model/category_state.dart';
import 'package:budget_wise/home/view_model/category_view_model.dart';
import 'package:budget_wise/home/view_model/transaction_state.dart';
import 'package:budget_wise/home/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDetailScreen extends StatelessWidget {
  static const String routeName = '/accountDetail';

  const AccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final account = ModalRoute.of(context)!.settings.arguments as AccountModel;
    final authRepo = context.read<AuthRepository>();
    final userName = authRepo.currentUser?.displayName ?? '';
    final categoryState = context.watch<CategoryBloc>().state;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(account.title, style: AppTextStyles.heading3),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIcons.trash(PhosphorIconsStyle.regular),
              color: AppColors.danger,
            ),
            onPressed: () {
              context.read<AccountBloc>().add(
                AccountEventDeleteAccount(accountId: account.id),
              );
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          //* Hero Balance Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    '\$${account.balance.toStringAsFixed(2)}',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.recentTransactions, // Placeholder for "Updated X ago"
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //* Credit Card Section (Conditional)
          if (account.accountType == AccountType.card) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CreditCardPreview(
                  bankName: account.cardBankName ?? '',
                  cardNumber: account.cardNumber ?? '',
                  cardHolderName: userName,
                  expiryDate: account.cardExpiryDate ?? '',
                  cardType: account.cardBrand ?? CardBrand.visa,
                ),
              ),
            ),
          ],

          //* Edit Account Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(EditAccountScreen.routeName, arguments: account);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
                      color: AppColors.textInverse,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10n.editAccount,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //* Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.recentTransactions, style: AppTextStyles.heading3),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AllTransactionsScreen.routeName,
                        arguments: {
                          'isNavFromAccount': true,
                          'accountModel': account,
                        },
                      );
                    },
                    child: Text(
                      l10n.viewAll,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //* Recent Transactions List
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              final transactions = state.transactionsList
                  .where((t) => t.accountId == account.id)
                  .take(10)
                  .toList();

              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        l10n.noDataThisMonth,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Group transactions by date
              final groupedTransactions = _groupTransactionsByDate(
                transactions,
                l10n,
              );

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = groupedTransactions.entries.toList()[index];
                  return _buildTransactionGroup(
                    context,
                    entry.key,
                    entry.value,
                    categoryState,
                  );
                }, childCount: groupedTransactions.length),
              );
            },
          ),

          //* Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl * 2)),
        ],
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      final txDate = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      String dateKey;
      if (txDate == today) {
        dateKey = l10n.today.toUpperCase();
      } else if (txDate == yesterday) {
        dateKey = l10n.yesterday.toUpperCase();
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(transaction.transactionDate);
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  Widget _buildTransactionGroup(
    BuildContext context,
    String dateLabel,
    List<TransactionModel> transactions,
    CategoryState categoryState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Date Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.cardBackground.withValues(alpha: 0.5),
          child: Text(
            dateLabel.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),

        //* Transaction Items
        ...transactions.map(
          (transaction) =>
              _buildTransactionItem(context, transaction, categoryState),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext contxt,
    TransactionModel transactionModel,
    CategoryState categoryState,
  ) {
    final isIncome = transactionModel.type == TransactionType.income;

    // Find category info
    final category = categoryState.categoriesList.firstWhere(
      (c) => c.id == transactionModel.categoryId,
      orElse: () => categoryState.categoriesList.isNotEmpty
          ? categoryState.categoriesList.first
          : throw Exception('No categories available'),
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(contxt).pushNamed(
          TransactionDetailScreen.routeName,
          arguments: transactionModel,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            //* Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.primaryAccent.withValues(alpha: 0.1)
                    : AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isIncome
                      ? AppColors.primaryAccent.withValues(alpha: 0.2)
                      : AppColors.expense.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                category.categoryIcon,
                color: isIncome ? AppColors.primaryAccent : AppColors.expense,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            //* Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionModel.transactionTitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.categoryTitle} • ${DateFormat('h:mm a').format(transactionModel.transactionDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            //* Amount
            Text(
              '${isIncome ? '+' : '-'}\$${transactionModel.transactionAmount.toStringAsFixed(2)}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isIncome ? AppColors.primaryAccent : AppColors.expense,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
