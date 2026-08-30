import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignUp;
  final VoidCallback onGoogleLogin;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSignUp,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Input
          CustomTextField(
            hintText: context.l10n.name,
            controller: nameController,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Email Input
          CustomTextField(
            hintText: context.l10n.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.emailRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Input
          CustomTextField(
            hintText: context.l10n.password,
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.passwordRequired;
              }

              if (value.length < 6) {
                return context.l10n.passwordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Sign Up Button
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthStateLoading || previous is AuthStateLoading,
            builder: (context, state) {
              return RepaintBoundary(
                child: CustomButton(
                  text: context.l10n.createAccount,
                  onPressed: onSignUp,
                  isLoading: state is AuthStateLoading,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Google Login Button
          RepaintBoundary(
            child: CustomButton(
              text: context.l10n.loginWithGoogle,
              type: CustomButtonType.secondary,
              onPressed: onGoogleLogin,
              leftIcon: Icon(PhosphorIconsBold.googleLogo),
            ),
          ),
        ],
      ),
    );
  }
}
