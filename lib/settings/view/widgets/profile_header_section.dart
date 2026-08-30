import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ProfileHeaderSection extends StatelessWidget {
  final User user;
  final AuthRepository authRepository;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.profile, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryAccent,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Text(
                        (user.displayName ?? "U").substring(0, 1).toUpperCase(),
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textInverse,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? '',
                      style: AppTextStyles.heading3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (authRepository.isEmailPasswordProvider) ...[
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(EditProfileScreen.routeName);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    PhosphorIconsRegular.pencil,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.editProfile, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
