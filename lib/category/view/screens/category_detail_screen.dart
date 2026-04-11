import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view/screens/add_category_screen.dart';
import 'package:budget_wise/category/view/widgets/category_app_bar_title.dart';
import 'package:budget_wise/category/view/widgets/category_detail_header.dart';
import 'package:budget_wise/category/view/widgets/category_transaction_list.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const String routeName = '/category-detail';

  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final categoryId = args?['categoryId'] as String?;

    if (categoryId == null) {
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
                  'This Category Is Not Available',
                  style: AppTextStyles.bodyLarge,
                ),
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

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final category = state.categoriesList.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => CategoryModel.empty(),
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
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: CategoryAppBarTitle(categoryId: categoryId),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddCategoryScreen(
                        categoryToEdit: category,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: AppColors.danger,
                ),
                onPressed: () {
                  final catBloc = context.read<CategoryBloc>();

                  AppToast.show(
                    context,
                    type: AppToastType.deleteWithUndo,
                    title: l10n.categoryDeleted,
                    onCompleted: () {
                      catBloc.add(
                        CategoryEventDeleteCategory(categoryId: categoryId),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryDetailHeader(categoryId: categoryId),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.recentExpenses,
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: CategoryTransactionList(categoryId: categoryId),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              ],
            ),
          ),
        );
      },
    );
  }
}


