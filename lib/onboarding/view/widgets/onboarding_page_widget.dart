import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final IconData? placeholderIcon;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(
                      placeholderIcon ?? Icons.image,
                      size: 64 * 2.5,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
