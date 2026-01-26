import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class IconPickerBottomSheet extends StatelessWidget {
  final Function(IconData) onIconSelected;

  const IconPickerBottomSheet({super.key, required this.onIconSelected});

  static final List<IconData> _availableIcons = [
    PhosphorIcons.fire(PhosphorIconsStyle.regular),
    PhosphorIcons.forkKnife(PhosphorIconsStyle.regular),
    PhosphorIcons.briefcase(PhosphorIconsStyle.regular),
    PhosphorIcons.filmStrip(PhosphorIconsStyle.regular),
    PhosphorIcons.coffee(PhosphorIconsStyle.regular),
    PhosphorIcons.shoppingBag(PhosphorIconsStyle.regular),
    PhosphorIcons.car(PhosphorIconsStyle.regular),
    PhosphorIcons.lightbulb(PhosphorIconsStyle.regular),
    PhosphorIcons.house(PhosphorIconsStyle.regular),
    PhosphorIcons.airplane(PhosphorIconsStyle.regular),
    PhosphorIcons.barbell(PhosphorIconsStyle.regular),
    PhosphorIcons.book(PhosphorIconsStyle.regular),
    PhosphorIcons.camera(PhosphorIconsStyle.regular),
    PhosphorIcons.gameController(PhosphorIconsStyle.regular),
    PhosphorIcons.gift(PhosphorIconsStyle.regular),
    PhosphorIcons.graduationCap(PhosphorIconsStyle.regular),
    PhosphorIcons.heart(PhosphorIconsStyle.regular),
    PhosphorIcons.musicNote(PhosphorIconsStyle.regular),
    PhosphorIcons.pawPrint(PhosphorIconsStyle.regular),
    PhosphorIcons.phone(PhosphorIconsStyle.regular),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text("Select Icon", style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    onIconSelected(_availableIcons[index]);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      _availableIcons[index],
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
