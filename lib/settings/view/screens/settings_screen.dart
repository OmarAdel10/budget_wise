import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../auth/view/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricEnabled = false;
  String _selectedLanguage = 'en';
  final AuthRepository _authRepository = AuthRepository();

  void _handleLogout() {
    context.read<AuthBloc>().add(AuthEventSignOut());
    if (_authRepository.currentUser == null) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
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
              Text("Profile", style: AppTextStyles.heading3),
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
                      backgroundImage: authRepository.currentUser!.photoURL != null
                          ? NetworkImage(
                              authRepository.currentUser!.photoURL!,
                            )
                          : null,
                      child: authRepository.currentUser!.photoURL == null
                          ? Text(
                              "U",
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.textInverse,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authRepository.currentUser!.displayName!, style: AppTextStyles.heading3),
                        Text(
                          authRepository.currentUser!.email!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // App Settings Section
              Text("App Settings", style: AppTextStyles.heading3),
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
                                  "Security",
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  "Fingerprint",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isBiometricEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isBiometricEnabled = value;
                            });
                          },
                          activeThumbColor: AppColors.primaryAccent,
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.3,
                          ),
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
                            Text("Language", style: AppTextStyles.bodyLarge),
                          ],
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            dropdownColor: AppColors.cardBackground,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(
                                  "English",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text(
                                  "Arabic",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // About Section
              Text("About", style: AppTextStyles.heading3),
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
                        Text("App Version", style: AppTextStyles.bodyLarge),
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
                        IconButton(
                          icon: Icon(
                            PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            PhosphorIcons.linkedinLogo(
                              PhosphorIconsStyle.regular,
                            ),
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {},
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
                    "Log Out",
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
