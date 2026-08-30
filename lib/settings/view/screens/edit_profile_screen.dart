import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/settings/view/widgets/edit_profile_warning_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
  bool _isLoadingDialogShowing = false;

  void _hideLoadingDialog() {
    if (_isLoadingDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogShowing = false;
    }
  }

  void _showLoadingDialog() {
    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
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
            Center(child: Text(context.l10n.loading)),
          ],
        ),
      ),
    ).then((_) => _isLoadingDialogShowing = false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hideLoadingDialog();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authRepository.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            final authRepository = context.read<AuthRepository>();
            if (state is AuthStateLoading) {
              _showLoadingDialog();
            } else if (state is AuthStateError) {
              _hideLoadingDialog();
              AppToast.show(
                context,
                type: AppToastType.error,
                title: state.message,
              );
            } else if (state is AuthStateSuccess) {
              _hideLoadingDialog();
              if (authRepository.currentUser != null && mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  context.l10n.editProfile,
                  style: AppTextStyles.heading3,
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const EditProfileWarningCard(),
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextField(
                      hintText: user?.displayName ?? context.l10n.name,
                      controller: _nameController,
                      prefixIcon: const Icon(
                        PhosphorIconsRegular.user,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      hintText: user?.email ?? context.l10n.email,
                      controller: _emailController,
                      readOnly: true,
                      enabled: false,
                      prefixIcon: const Icon(
                        PhosphorIconsRegular.envelope,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      hintText: context.l10n.newPassword,
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(
                        PhosphorIconsRegular.lock,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    CustomButton(
                      text: context.l10n.saveChanges,
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
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
