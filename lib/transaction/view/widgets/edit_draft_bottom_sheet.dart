import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/date_picker_field.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/transaction/view/widgets/amount_field.dart';
import 'package:budget_wise/transaction/view/widgets/description_field.dart';
import 'package:budget_wise/shared/widgets/type_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class EditDraftBottomSheet extends StatefulWidget {
  final String title;
  final double amount;
  final DateTime? date;
  final TransactionType? type;
  final String? currency;

  const EditDraftBottomSheet({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.currency,
  });

  @override
  State<EditDraftBottomSheet> createState() => _EditDraftBottomSheetState();
}

class _EditDraftBottomSheetState extends State<EditDraftBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  late final ValueNotifier<DateTime> selectedDate;
  late final ValueNotifier<TransactionType> selectedType;
  late final ValueNotifier<String?> selectedCurrency;
  final FocusNode titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final defaultCurrency = context.read<SettingsBloc>().state.currencySymbol;
    titleController = TextEditingController(text: widget.title);
    amountController = TextEditingController(
      text: widget.amount.toStringAsFixed(0),
    );
    selectedDate = ValueNotifier(DateTime.now());
    selectedType = ValueNotifier(TransactionType.expense);
    selectedCurrency = ValueNotifier(defaultCurrency);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.currency != null && widget.currency!.isNotEmpty) {
      selectedCurrency.value = widget.currency;
    }
    if (widget.date != null) {
      selectedDate.value = widget.date!;
    }
    if (widget.type != null) {
      selectedType.value = widget.type!;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    selectedDate.dispose();
    selectedType.dispose();
    selectedCurrency.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  Color get activeColor => selectedType.value == TransactionType.income
      ? AppColors.income
      : AppColors.expense;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _EditDraftContent(
          scrollController: scrollController,
          titleController: titleController,
          amountController: amountController,
          selectedDate: selectedDate,
          selectedType: selectedType,
          selectedCurrency: selectedCurrency,
          titleFocusNode: titleFocusNode,
          activeColor: activeColor,
        ),
      ),
    );
  }
}

class _EditDraftContent extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<TransactionType> selectedType;
  final ValueNotifier<String?> selectedCurrency;
  final FocusNode titleFocusNode;
  final Color activeColor;
  const _EditDraftContent({
    required this.scrollController,
    required this.titleController,
    required this.amountController,
    required this.selectedDate,
    required this.selectedType,
    required this.selectedCurrency,
    required this.titleFocusNode,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                BottomSheetService.header(
                  title: context.l10n.editDraft,
                  hasDrag: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                TypeTabBar.forTransactionTypes(
                  selectionNotifier: selectedType,
                  isScrollable: false,
                  padding: EdgeInsets.zero,
                  enableTransferTab: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                AmountField(
                  amountController: amountController,
                  selectedCurrency: selectedCurrency,
                ),
                const SizedBox(height: AppSpacing.lg),
                DescriptionField(
                  isTitle: true,
                  controller: titleController,
                  focusNode: titleFocusNode,
                  selectedType: selectedType.value,
                ),
                const SizedBox(height: AppSpacing.lg),
                DatePickerField(
                  label: context.l10n.dateLabel,
                  selectedDate: selectedDate,
                  activeColor: activeColor,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'title': titleController.text.trim(),
                      'amount':
                          double.tryParse(amountController.text.trim()) ?? 0.0,
                      'date': selectedDate.value,
                      'type': selectedType.value,
                      'currency': selectedCurrency.value,
                    });
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
                        PhosphorIconsBold.pencilSimple,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.saveChanges,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
