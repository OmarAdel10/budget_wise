import 'package:budget_wise/accounts/data/data_source/account_constants.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class BankPickerBottomSheet extends StatefulWidget {
  final Function(String bankName, List<String> senderIds) onBankSelected;

  const BankPickerBottomSheet({super.key, required this.onBankSelected});

  @override
  State<BankPickerBottomSheet> createState() => _BankPickerBottomSheetState();
}

class _BankPickerBottomSheetState extends State<BankPickerBottomSheet> {
  String _searchQuery = '';
  List<MapEntry<String, List<String>>> _filteredBanks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterBanks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    setState(() {
      _filteredBanks = AccountConstants.egyptBanks.entries.where((entry) {
        final bankName = entry.key.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return bankName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      shouldCloseOnMinExtent: false,

      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.l10n.selectBankTitle,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _searchController,
                      hintText: context.l10n.searchBankPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterBanks();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _filteredBanks.length,
                  itemBuilder: (context, index) {
                    final bankEntry = _filteredBanks[index];
                    final bankName = bankEntry.key;
                    final senderIds = bankEntry.value;
                    final logoFileName = bankName.toLowerCase().replaceAll(
                      ' ',
                      '',
                    );
                    final logoPath = 'assets/bank_logos/$logoFileName.png';

                    return GestureDetector(
                      onTap: () {
                        widget.onBankSelected(bankName, senderIds);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: MediaQuery.sizeOf(context).height * .065,
                              width: MediaQuery.sizeOf(context).width * .23,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                              ),
                              child: Image.asset(logoPath, fit: BoxFit.contain),
                            ),
                            Text(
                              bankName,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
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
