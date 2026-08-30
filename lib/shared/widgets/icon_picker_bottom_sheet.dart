import 'package:budget_wise/buckets/view/widgets/savings_color_picker.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/data/services/search_service.dart';
import 'package:budget_wise/shared/utils/icon_all.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class IconPickerBottomSheet extends StatefulWidget {
  final Function(IconData) onIconSelected;
  final Color? accentColor;
  final bool hasColorPalete;
  final ValueNotifier<Color>? selectedColorNotifier;

  const IconPickerBottomSheet({
    super.key,
    required this.onIconSelected,
    this.accentColor,
  }) : selectedColorNotifier = null,
       hasColorPalete = false;

  const IconPickerBottomSheet.hasColorPalete({
    super.key,
    required this.selectedColorNotifier,
    required this.onIconSelected,
  }) : hasColorPalete = true,
       accentColor = null;

  static final Map<String, IconData> _availableIcons =
      PhosphorIcons().allRegularIconsWithName;

  @override
  State<IconPickerBottomSheet> createState() => _IconPickerBottomSheetState();
}

class _IconPickerBottomSheetState extends State<IconPickerBottomSheet> {
  late final SearchService<MapEntry<String, IconData>> _searchService;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService<MapEntry<String, IconData>>(
      initialSource: IconPickerBottomSheet._availableIcons.entries.toList(),
      searchFieldsExtractor: (entry) => [entry.key],
    );
  }

  // void syncIcons() {}

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BottomSheetService.headerWithSearch(
            headerTitle: context.l10n.selectIcon,
            searchHintText: 'Search For An Icon',
            searchController: _searchService.searchController,
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.hasColorPalete &&
              widget.selectedColorNotifier != null) ...[
            SavingGoalColorPicker(
              selectedColorNotifier: widget.selectedColorNotifier!,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ValueListenableBuilder<List<MapEntry<String, IconData>>>(
              valueListenable: _searchService.filteredListNotifier,
              builder: (context, filteredList, child) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final title = filteredList[index].key;
                    final icon = filteredList[index].value;
                    return GestureDetector(
                      onTap: () {
                        widget.onIconSelected(icon);
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        children: [
                          GenericIconContainer(
                            icon: icon,
                            size: 50,
                            iconSize: 30,
                            color: widget.accentColor ?? AppColors.textPrimary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            title
                                .replaceAll(RegExp(r'[_-]'), ' ')
                                .toTitleCase(),
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
