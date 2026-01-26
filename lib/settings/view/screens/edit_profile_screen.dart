import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthRepository authRepository;
  static const String routeName = '/edit-profile';

  const EditProfileScreen({super.key, required this.authRepository});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = widget.authRepository.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(l10n.editProfile, style: AppTextStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final AuthRepository authRepository = context
                  .read<AuthRepository>();
              if (state is AuthStateLoading) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    scrollable: false,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height * 0.25,
                      maxHeight: MediaQuery.sizeOf(context).height * 0.25,
                      minWidth: MediaQuery.sizeOf(context).width * 0.75,
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: AppSpacing.md),
                        const Center(child: Text('Loading...')),
                      ],
                    ),
                  ),
                );
                final navigator = Navigator.of(context);
                Future.delayed(const Duration(milliseconds: 1200)).then((_) {
                  if (mounted) {
                    navigator.pop();
                  }
                });
              }
              if (state is AuthStateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              if (state is AuthStateSuccess) {
                if (authRepository.currentUser != null && mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Column(
              children: [
                // Warning Container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.warning(PhosphorIconsStyle.regular),
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        "${l10n.redBorderMeansThatYouCantChange}\n${l10n.thisFielditsOnlyForDisplay}",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize:
                              context
                                      .read<SettingsBloc>()
                                      .state
                                      .model
                                      .language ==
                                  'en'
                              ? 11.3
                              : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Profile Picture
                // Center(
                //   child: Stack(
                //     children: [
                //       CircleAvatar(
                //         radius: 60,
                //         backgroundColor: AppColors.cardBackground,
                //         backgroundImage: user?.photoURL != null
                //             ? NetworkImage(user!.photoURL!)
                //             : null,
                //         child: user?.photoURL == null
                //             ? Text(
                //                 (user?.displayName ?? 'U')[0].toUpperCase(),
                //                 style: AppTextStyles.heading1.copyWith(
                //                   fontSize: 40,
                //                 ),
                //               )
                //             : null,
                //       ),
                //       Positioned(
                //         bottom: 0,
                //         right: 0,
                //         child: Container(
                //           padding: const EdgeInsets.all(AppSpacing.xs),
                //           decoration: const BoxDecoration(
                //             color: AppColors.primaryAccent,
                //             shape: BoxShape.circle,
                //           ),
                //           child: Icon(
                //             PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                //             size: 20,
                //             color: AppColors.textInverse,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: AppSpacing.xxl),

                // Name Field
                CustomTextField(
                  hintText: user?.displayName ?? l10n.name,
                  controller: _nameController,
                  prefixIcon: Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.regular),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Email Field
                CustomTextField(
                  hintText: user?.email ?? l10n.email,
                  controller: _emailController,
                  readOnly: true,
                  enabled: false,
                  prefixIcon: Icon(
                    PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password Field
                CustomTextField(
                  hintText: l10n.newPassword,
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icon(
                    PhosphorIcons.lock(PhosphorIconsStyle.regular),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Save Button
                CustomButton(
                  text: l10n.saveChanges,
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      context.read<AuthBloc>().add(
                        AuthEventEditProfileChangeName(
                          name: _nameController.text,
                        ),
                      );
                    }
                    if (_passwordController.text.isNotEmpty) {
                      context.read<AuthBloc>().add(
                        AuthEventEditProfileChangePassword(
                          password: _passwordController.text,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
