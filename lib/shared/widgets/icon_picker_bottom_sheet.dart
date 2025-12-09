import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/text_styles.dart';

class IconPickerBottomSheet extends StatelessWidget {
  final Function(IconData) onIconSelected;

  const IconPickerBottomSheet({
    super.key,
    required this.onIconSelected,
  });

  // Curated list of icons suitable for categories and saving goals
  static const List<IconData> _availableIcons = [
    PhosphorIconsRegular.house,
    PhosphorIconsRegular.car,
    PhosphorIconsRegular.shoppingBag,
    PhosphorIconsRegular.forkKnife,
    PhosphorIconsRegular.coffee,
    PhosphorIconsRegular.filmSlate,
    PhosphorIconsRegular.airplane,
    PhosphorIconsRegular.firstAid,
    PhosphorIconsRegular.graduationCap,
    PhosphorIconsRegular.briefcase,
    PhosphorIconsRegular.gift,
    PhosphorIconsRegular.gameController,
    PhosphorIconsRegular.barbell,
    PhosphorIconsRegular.pawPrint,
    PhosphorIconsRegular.baby,
    PhosphorIconsRegular.book,
    PhosphorIconsRegular.videoCamera,
    PhosphorIconsRegular.musicNote,
    PhosphorIconsRegular.money,
    PhosphorIconsRegular.creditCard,
    PhosphorIconsRegular.piggyBank,
    PhosphorIconsRegular.chartLine,
    PhosphorIconsRegular.percent,
    PhosphorIconsRegular.tag,
    PhosphorIconsRegular.lightning,
    PhosphorIconsRegular.lightbulb,
    PhosphorIconsRegular.fire,
    PhosphorIconsRegular.drop,
    PhosphorIconsRegular.phone,
    PhosphorIconsRegular.wifiHigh,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Select Icon',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: GridView.builder(
              itemCount: _availableIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                return InkWell(
                  onTap: () => onIconSelected(icon),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.textPrimary,
                      size: 28,
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
