import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart' show HomeBloc;
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const String routeName = '/transaction-detail';

  final TransactionModel transModel;

  const TransactionDetailScreen({super.key, required this.transModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          transModel.type == TransactionType.income
              ? l10n.incomeDetails
              : l10n.expenseDetails,
          style: TextStyle(
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
              // Amount Header
              Center(
                child: Column(
                  children: [
                    Text(
                      transModel.type == TransactionType.income
                          ? l10n.amountReceived
                          : l10n.amountSpent,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "\$${transModel.transactionAmount}",
                      style: AppTextStyles.heading1.copyWith(
                        color: transModel.type == TransactionType.income
                            ? AppColors.primaryAccent
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Detail Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    _buildDetailItem(
                      icon: PhosphorIcons.tag(),
                      label: l10n.title,
                      value: transModel.transactionTitle,
                    ),
                    const Divider(
                      color: AppColors.borderColor,
                      height: AppSpacing.xl,
                    ),
                    _buildDetailItem(
                      icon: PhosphorIcons.calendar(),
                      label: l10n.date,
                      value: DateFormat(
                        "dd/MM/yyyy | hh:mm",
                      ).format(transModel.transactionDate),
                    ),
                    const Divider(
                      color: AppColors.borderColor,
                      height: AppSpacing.xl,
                    ),
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        return _buildDetailItem(
                          icon: PhosphorIcons.listBullets(),
                          label: l10n.category,
                          value: state.model.categories
                              .firstWhere(
                                (category) =>
                                    category.category.id ==
                                    transModel.categoryId,
                              )
                              .category
                              .categoryTitle,
                        );
                      },
                    ),
                    if (transModel.transactionNotes != null &&
                        transModel.transactionNotes!.isNotEmpty) ...[
                      const Divider(
                        color: AppColors.borderColor,
                        height: AppSpacing.xl,
                      ),
                      _buildDetailItem(
                        icon: PhosphorIcons.note(),
                        label: l10n.notes,
                        value: transModel.transactionNotes!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement Edit
                      },
                      icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                      label: Text(l10n.edit),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(color: AppColors.primaryAccent),
                        foregroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement Delete
                      },
                      icon: Icon(PhosphorIcons.trash(), size: 20),
                      label: Text(l10n.delete),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, color: AppColors.primaryAccent, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
