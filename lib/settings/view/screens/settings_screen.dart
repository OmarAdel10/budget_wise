import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/screens/edit_profile_screen.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/link.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../auth/view/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _handleLogout() {
    context.read<AuthBloc>().add(AuthEventSignOut());
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final linkedInUri = Uri.parse('https://www.linkedin.com/in/omaradel10');
    final emailUri = Uri(scheme: 'mailto', path: 'omaradel1.dev@gmail.com');
    final AuthRepository authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.navSettings,
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
              // Profile Section
              Text(l10n.profile, style: AppTextStyles.heading3),
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
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              (user?.displayName ?? "U")
                                  .substring(0, 1)
                                  .toUpperCase(),
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
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return Text(
                                user?.displayName ?? '',
                                style: AppTextStyles.heading3,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          Text(
                            user?.email ?? '',
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
              authRepository.isEmailPasswordProvider
                  ? Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(EditProfileScreen.routeName);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.pencil(
                                    PhosphorIconsStyle.regular,
                                  ),
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.editProfile,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: AppSpacing.xl),

              // App Settings Section
              Text(l10n.appSettings, style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.fingerprint(
                                PhosphorIconsStyle.regular,
                              ),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.security,
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  l10n.bioMetrics,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return Switch(
                              value: state.model.localAuthEnabled,
                              onChanged: (value) {
                                context.read<SettingsBloc>().add(
                                  const SettingsEventLocalAuth(),
                                );
                              },
                              activeThumbColor: AppColors.primaryAccent,
                              activeTrackColor: AppColors.primaryAccent
                                  .withValues(alpha: 0.3),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.regular),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(l10n.syncToCloud),
                          ],
                        ),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return Switch(
                              value: state.model.isSyncToCloudEnabled,
                              onChanged: (value) {
                                context.read<SettingsBloc>().add(
                                  SettingsEventSyncToCloud(),
                                );
                              },
                              activeThumbColor: AppColors.primaryAccent,
                              activeTrackColor: AppColors.primaryAccent
                                  .withValues(alpha: 0.3),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.globe(PhosphorIconsStyle.regular),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(l10n.language, style: AppTextStyles.bodyLarge),
                          ],
                        ),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.model.language == 'en'
                                    ? 'en'
                                    : 'ar',
                                dropdownColor: AppColors.cardBackground,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textSecondary,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text(
                                      l10n.english,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ar',
                                    child: Text(
                                      l10n.arabic,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (String? newLangCode) {
                                  if (newLangCode != null) {
                                    context.read<SettingsBloc>().add(
                                      SettingsEventLanguageChange(newLangCode),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // About Section
              Text(l10n.about, style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.appVersion, style: AppTextStyles.bodyLarge),
                        Text(
                          "v1.0.0",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Link(
                          uri: emailUri,
                          target: LinkTarget.blank,
                          builder: (context, followLink) => IconButton(
                            icon: Icon(
                              PhosphorIcons.envelope(
                                PhosphorIconsStyle.regular,
                              ),
                              color: AppColors.textSecondary,
                            ),
                            onPressed: followLink,
                          ),
                        ),
                        Link(
                          uri: linkedInUri,
                          target: LinkTarget.blank,
                          builder: (context, followLink) => IconButton(
                            icon: Icon(
                              PhosphorIcons.linkedinLogo(
                                PhosphorIconsStyle.regular,
                              ),
                              color: AppColors.textSecondary,
                            ),
                            onPressed: followLink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _handleLogout,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(
                    l10n.logout,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
