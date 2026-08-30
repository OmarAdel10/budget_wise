import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view/screens/add_category_bottom_sheet.dart';
import 'package:budget_wise/category/view/widgets/category_detail_header.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/transaction_list_view.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.categoryId == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.xCircle,
                  color: AppColors.danger,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.categoryNotFound,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomButton(
                  text: context.l10n.returnToHome,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final category = state.categoriesList.firstWhere(
          (cat) => cat.id == widget.categoryId,
          orElse: () => CategoryModel.empty(),
        );

        final transactions = context
            .select<TransactionBloc, List<TransactionModel>>(
              (bloc) => bloc.state.transactionsList
                  .where((trans) => trans.categoryId == category.id)
                  .toList(),
            );

        if (category.id.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsBold.warning,
                      color: AppColors.danger,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Category Not Found', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: 'Return To Home Screen',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BottomSheetService.header(
                  title: category.categoryTitle.toTitleCase(),
                  hasPadding: true,
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  actions: !category.isDefault
                      ? [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              BottomSheetService.pageRoute(
                                child: (context) => AddCategoryBottomSheet(
                                  categoryToEdit: category,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.trash,
                              color: AppColors.danger,
                            ),
                            onPressed: () {
                              final catBloc = context.read<CategoryBloc>();

                              AppToast.show(
                                context,
                                type: AppToastType.deleteWithUndo,
                                title: context.l10n.categoryDeleted,
                                description:
                                    context.l10n.undoDeletionDescription,
                                onCompleted: () {
                                  Navigator.of(context).pop();
                                  catBloc.add(
                                    CategoryEventDeleteCategory(
                                      categoryId: category.id,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ]
                      : null,
                ),
                CategoryDetailHeader(categoryId: category.id),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.recentExpenses,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: TransactionListView(
                    transactions: transactions,
                    padding: EdgeInsets.zero,
                    isRoot: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
