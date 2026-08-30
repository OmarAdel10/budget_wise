import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../main_navigation/view/screens/main_screen.dart';
import '../widgets/signup_footer.dart';
import '../widgets/signup_form.dart';
import '../widgets/signup_header.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEventSignUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onGoogleLogin() {
    context.read<AuthBloc>().add(AuthEventSignInWithGoogle());
  }

  @override
  Widget build(BuildContext context) {
    final isFromOnboarding =
        ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.createAccount,
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
              context.read<SettingsBloc>().add(const SettingsEventLoggedIn());

              context.read<TransactionBloc>().add(
                const TransactionEventSyncPendingOnLogin(),
              );

              context.read<CategoryBloc>().add(
                const CategoryEventSyncPendingOnLogin(),
              );

              context.read<AccountBloc>().add(
                const AccountEventSyncPendingOnLogin(),
              );

              if (isFromOnboarding) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName,
                  (route) => false,
                );
              }
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SignUpHeader(),
                      SignUpForm(
                        formKey: _formKey,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onSignUp: _onSignUp,
                        onGoogleLogin: _onGoogleLogin,
                      ),
                      const Spacer(),
                      SignUpFooter(isFromOnboarding: isFromOnboarding),
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
