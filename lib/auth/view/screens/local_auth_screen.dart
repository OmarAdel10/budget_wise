import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';

import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/shared/widgets/numeric_keypad.dart';
import 'package:budget_wise/shared/widgets/passcode_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class LocalAuthScreen extends StatefulWidget {
  static const String routeName = '/local_auth';
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<String> _passcodeNotifier;
  late final ValueNotifier<bool> _isErrorNotifier;
  late final ValueNotifier<bool> _isSuccessNotifier;
  bool _isBiometricTriggered = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _passcodeNotifier = ValueNotifier<String>('');
    _isErrorNotifier = ValueNotifier<bool>(false);
    _isSuccessNotifier = ValueNotifier<bool>(false);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _passcodeNotifier.dispose();
    _isErrorNotifier.dispose();
    _isSuccessNotifier.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isBiometricTriggered) {
      final settings = context.read<SettingsBloc>().state.model;
      if (settings.useBiometrics) {
        _triggerBiometrics();
      }
      _isBiometricTriggered = true;
    }
  }

  void _triggerBiometrics() {
    context.read<AuthBloc>().add(
      AuthEventLocalAuth(
        localizedReason: context.l10n.biometricReason,
        biometricNotAvailableErrorMessage: context.l10n.biometricNotAvailable,
      ),
    );
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    // Clear error state on new input
    if (_isErrorNotifier.value) {
      _isErrorNotifier.value = false;
    }

    if (_passcodeNotifier.value.length < 4) {
      _passcodeNotifier.value += digit;
      if (_passcodeNotifier.value.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    if (_isErrorNotifier.value) {
      _isErrorNotifier.value = false;
    }

    if (_passcodeNotifier.value.isNotEmpty) {
      _passcodeNotifier.value = _passcodeNotifier.value.substring(
        0,
        _passcodeNotifier.value.length - 1,
      );
    }
  }

  Future<void> _verifyPasscode() async {
    final settings = context.read<SettingsBloc>().state.model;
    if (_passcodeNotifier.value == settings.passcode) {
      _isSuccessNotifier.value = true;
      // Brief delay to show filled circles before navigating
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
      }
    } else {
      _isErrorNotifier.value = true;
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0).then((_) {
        _passcodeNotifier.value = '';
      });
      if (mounted) {
        AppToast.show(
          context,
          type: AppToastType.error,
          title: context.l10n.passcodeIncorrect,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final useBiometrics = context.select<SettingsBloc, bool>(
      (bloc) => bloc.state.model.useBiometrics,
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateSuccess) {
          // Fill circles visually on biometric success
          _passcodeNotifier.value = '****';
          _isSuccessNotifier.value = true;
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                PhosphorIconsRegular.lock,
                size: 80,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(context.l10n.enterPasscode, style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.xl),
              ValueListenableBuilder<String>(
                valueListenable: _passcodeNotifier,
                builder: (context, passcode, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isErrorNotifier,
                    builder: (context, isError, child) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isSuccessNotifier,
                        builder: (context, isSuccess, child) {
                          return AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value, 0),
                                child: PasscodeIndicator(
                                  inputLength: passcode.length,
                                  isError: isError,
                                  isSuccess: isSuccess,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _isSuccessNotifier,
                builder: (context, success, child) {
                  if (success) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryAccent.withValues(alpha: 0.7),
                        strokeWidth: 3,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Spacer(),
              NumericKeypad(
                onDigitPressed: _onDigitPressed,
                onBackspacePressed: _onBackspacePressed,
                leftButton: useBiometrics
                    ? IconButton(
                        icon: const Icon(
                          PhosphorIconsRegular.fingerprint,
                          color: AppColors.primaryAccent,
                          size: 32,
                        ),
                        onPressed: _triggerBiometrics,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
