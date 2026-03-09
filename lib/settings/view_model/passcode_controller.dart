import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class PasscodeSetupState extends Equatable {
  final String passcode;
  final String confirmPasscode;
  final bool isConfirming;

  const PasscodeSetupState({
    this.passcode = '',
    this.confirmPasscode = '',
    this.isConfirming = false,
  });

  PasscodeSetupState copyWith({
    String? passcode,
    String? confirmPasscode,
    bool? isConfirming,
  }) {
    return PasscodeSetupState(
      passcode: passcode ?? this.passcode,
      confirmPasscode: confirmPasscode ?? this.confirmPasscode,
      isConfirming: isConfirming ?? this.isConfirming,
    );
  }

  @override
  List<Object?> get props => [passcode, confirmPasscode, isConfirming];
}

class PasscodeController extends ValueNotifier<PasscodeSetupState> {
  PasscodeController() : super(const PasscodeSetupState());

  void addDigit(String digit) {
    if (!value.isConfirming) {
      if (value.passcode.length < 4) {
        final newPasscode = value.passcode + digit;
        value = value.copyWith(
          passcode: newPasscode,
          isConfirming: newPasscode.length == 4,
        );
      }
    } else {
      if (value.confirmPasscode.length < 4) {
        value = value.copyWith(confirmPasscode: value.confirmPasscode + digit);
      }
    }
  }

  void removeDigit() {
    if (!value.isConfirming) {
      if (value.passcode.isNotEmpty) {
        value = value.copyWith(
          passcode: value.passcode.substring(0, value.passcode.length - 1),
        );
      }
    } else {
      if (value.confirmPasscode.isNotEmpty) {
        value = value.copyWith(
          confirmPasscode: value.confirmPasscode.substring(
            0,
            value.confirmPasscode.length - 1,
          ),
        );
      } else {
        value = value.copyWith(
          isConfirming: false,
          passcode: value.passcode.substring(0, value.passcode.length - 1),
        );
      }
    }
  }

  void reset() {
    value = const PasscodeSetupState();
  }
}
