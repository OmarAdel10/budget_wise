import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
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
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LocalAuthScreen extends StatefulWidget {
  static const String routeName = '/local_auth';
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<String> _passcodeNotifier;
  bool _isBiometricTriggered = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _passcodeNotifier = ValueNotifier<String>('');
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
    final l10n = AppLocalizations.of(context)!;
    context.read<AuthBloc>().add(
      AuthEventLocalAuth(
        localizedReason: l10n.biometricReason,
        biometricNotAvailableErrorMessage: l10n.biometricNotAvailable,
      ),
    );
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    if (_passcodeNotifier.value.length < 4) {
      _passcodeNotifier.value += digit;
      if (_passcodeNotifier.value.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    if (_passcodeNotifier.value.isNotEmpty) {
      _passcodeNotifier.value = _passcodeNotifier.value.substring(
        0,
        _passcodeNotifier.value.length - 1,
      );
    }
  }

  void _verifyPasscode() {
    final settings = context.read<SettingsBloc>().state.model;
    if (_passcodeNotifier.value == settings.passcode) {
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0).then((_) {
        _passcodeNotifier.value = '';
      });
      AppToast.show(
        context,
        type: AppToastType.error,
        title: AppLocalizations.of(context)!.passcodeIncorrect,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useBiometrics = context.select<SettingsBloc, bool>(
      (bloc) => bloc.state.model.useBiometrics,
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateSuccess) {
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
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
              Text(l10n.enterPasscode, style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.xl),
              ValueListenableBuilder<String>(
                valueListenable: _passcodeNotifier,
                builder: (context, passcode, child) {
                  return AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: PasscodeIndicator(inputLength: passcode.length),
                      );
                    },
                  );
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
