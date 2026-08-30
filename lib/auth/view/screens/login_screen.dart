import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/utils/auth_constants.dart';
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
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/responsive_spacer.dart';
import '../../../main_navigation/view/screens/main_screen.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
import '../widgets/login_footer.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEventSignIn(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onGoogleLogin() {
    context.read<AuthBloc>().add(AuthEventSignInWithGoogle());
  }

  void _onForgotPassword() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.routeName);
  }

  void _onSignUp(bool isFromOnboarding) {
    if (isFromOnboarding) {
      Navigator.of(context).pop(AuthConstants.switchToSignup);
    } else {
      Navigator.of(context).pushReplacementNamed(
        SignUpScreen.routeName,
        arguments: isFromOnboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract args without causing full-screen rebuilds on layout changes
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isFromOnboarding =
        args?[AuthConstants.loginRoutingKey] == LoginRouting.fromOnboarding;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(
        title: context.l10n.appTitle,
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MainScreen.routeName,
                    (route) => false,
                  );
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ResponsiveSpacer(heightFraction: 0.2),
                const LoginHeader(),
                LoginForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onForgotPassword: _onForgotPassword,
                ),
                LoginFooter(
                  onLogin: _onLogin,
                  onGoogleLogin: _onGoogleLogin,
                  onSignUp: () => _onSignUp(isFromOnboarding),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
