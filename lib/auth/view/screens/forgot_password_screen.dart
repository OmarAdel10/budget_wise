import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/auth/view/widgets/forgot_password_footer.dart';
import 'package:budget_wise/auth/view/widgets/forgot_password_form.dart';
import 'package:budget_wise/auth/view/widgets/forgot_password_header.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  void _onLogin(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.forgotPassword,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthStateError) {
              AppToast.show(
                context,
                type: AppToastType.error,
                title: state.message,
              );
            }
            if (state is AuthStateSuccess) {
              Navigator.of(context).pop();
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),

                      // Heading
                      ForgotPasswordHeader(title: context.l10n.enterEmail),
                      const SizedBox(height: AppSpacing.xl),

                      // Reset Form
                      ForgotPasswordForm(
                        emailHint: context.l10n.email,
                        emailRequiredError: context.l10n.emailRequired,
                        sendResetLinkText: context.l10n.sendResetLink,
                      ),

                      const Spacer(flex: 3),

                      // Login Link (Footer)
                      ForgotPasswordFooter(
                        rememberPasswordText: context.l10n.rememberPassword,
                        loginText: context.l10n.login,
                        onLoginPressed: () => _onLogin(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
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
