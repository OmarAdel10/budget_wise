import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class LocalAuthScreen extends StatefulWidget {
  static const String routeName = '/local_auth';
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  bool _hasAuthenticated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAuthenticated) {
      final l10n = AppLocalizations.of(context)!;
      context.read<AuthBloc>().add(
        AuthEventLocalAuth(
          localizedReason: l10n.biometricReason,
          biometricNotAvailableErrorMessage: l10n.biometricNotAvailable,
        ),
      );
      _hasAuthenticated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateSuccess) {
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
        }
        if (state is AuthStateError) {
          setState(() {
            _hasAuthenticated = false;
          });
          toastification.show(
            autoCloseDuration: const Duration(seconds: 3),
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            title: Text(state.message),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.appTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 80,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.biometricReason,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    AuthEventLocalAuth(
                      localizedReason: l10n.biometricReason,
                      biometricNotAvailableErrorMessage:
                          l10n.biometricNotAvailable,
                    ),
                  );
                },
                child: Text(l10n.tryAgainLocally),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
