import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEventResetPassword(email: _emailController.text),
      );
    }
  }

  void _onLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          l10n.forgotPassword,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: IntrinsicHeight(
                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthStateLoading) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              scrollable: false,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * 0.25,
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * 0.25,
                                minWidth:
                                    MediaQuery.sizeOf(context).width * 0.75,
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * 0.75,
                              ),
                              content: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Center(child: Text(l10n.loading)),
                                ],
                              ),
                            ),
                          );
                        }
                        if (state is AuthStateError) {
                          Navigator.of(context).pop();
                          toastification.show(
                            autoCloseDuration: const Duration(seconds: 3),
                            context: context,
                            type: ToastificationType.error,
                            style: ToastificationStyle.flatColored,
                            title: Text(state.message),
                          );
                        }
                        if (state is AuthStateSuccess) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 4,
                            ),

                            // Heading
                            Text(
                              l10n.enterEmail,
                              style: AppTextStyles.heading2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Email Input
                            CustomTextField(
                              hintText: l10n.email,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.emailRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Send Reset Link Button
                            CustomButton(
                              text: l10n.sendResetLink,
                              onPressed: _onSendResetLink,
                            ),

                            const Spacer(),

                            // Login Link (Footer)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.rememberPassword,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _onLogin,
                                  child: Text(
                                    l10n.login,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
