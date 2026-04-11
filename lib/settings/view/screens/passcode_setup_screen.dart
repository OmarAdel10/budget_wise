import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/passcode_controller.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/numeric_keypad.dart';
import 'package:budget_wise/shared/widgets/passcode_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PasscodeSetupScreen extends StatefulWidget {
  static const String routeName = '/passcode_setup';
  const PasscodeSetupScreen({super.key});

  @override
  State<PasscodeSetupScreen> createState() => _PasscodeSetupScreenState();
}

class _PasscodeSetupScreenState extends State<PasscodeSetupScreen> {
  late final PasscodeController _passcodeController;
  late final ValueNotifier<bool> _isErrorNotifier;
  late final ValueNotifier<bool> _isSuccessNotifier;

  @override
  void initState() {
    super.initState();
    _passcodeController = PasscodeController();
    _isErrorNotifier = ValueNotifier<bool>(false);
    _isSuccessNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    _isErrorNotifier.dispose();
    _isSuccessNotifier.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    if (_isErrorNotifier.value) {
      _isErrorNotifier.value = false;
    }

    _passcodeController.addDigit(digit);
    if (_passcodeController.value.isConfirming &&
        _passcodeController.value.confirmPasscode.length == 4) {
      _verifyAndSave();
    }
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    if (_isErrorNotifier.value) {
      _isErrorNotifier.value = false;
    }
    _passcodeController.removeDigit();
  }

  Future<void> _verifyAndSave() async {
    final l10n = AppLocalizations.of(context)!;
    final state = _passcodeController.value;

    if (state.passcode == state.confirmPasscode) {
      _isSuccessNotifier.value = true;
      context.read<SettingsBloc>().add(
        SettingsEventUpdatePasscode(state.passcode),
      );
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passcodeSet),
            backgroundColor: AppColors.primaryAccent,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      _isErrorNotifier.value = true;
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      _passcodeController.reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passcodeMismatch),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.caretLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(
              PhosphorIconsRegular.lock,
              size: 64,
              color: AppColors.primaryAccent,
            ),
            const SizedBox(height: AppSpacing.lg),
            ValueListenableBuilder<PasscodeSetupState>(
              valueListenable: _passcodeController,
              builder: (context, state, _) {
                final currentInputLength =
                    state.isConfirming
                        ? state.confirmPasscode.length
                        : state.passcode.length;

                return Column(
                  children: [
                    Text(
                      state.isConfirming
                          ? l10n.confirmPasscode
                          : l10n.enterPasscode,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isErrorNotifier,
                      builder: (context, isError, child) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isSuccessNotifier,
                          builder: (context, isSuccess, child) {
                            return PasscodeIndicator(
                              inputLength: currentInputLength,
                              isError: isError,
                              isSuccess: isSuccess,
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            NumericKeypad(
              onDigitPressed: _onDigitPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
