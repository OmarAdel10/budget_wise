import 'package:budget_wise/settings/view_model/passcode_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasscodeController Tests', () {
    test('initial state is correct', () {
      final controller = PasscodeController();
      expect(controller.value, const PasscodeSetupState());
      expect(controller.value.passcode, '');
      expect(controller.value.confirmPasscode, '');
      expect(controller.value.isConfirming, false);
    });

    test('reset() sets state back to initial', () {
      final controller = PasscodeController();
      controller.value = const PasscodeSetupState(
        passcode: '1234',
        isConfirming: true,
      );
      controller.reset();
      expect(controller.value, const PasscodeSetupState());
    });

    test('addDigit appends digits to passcode when not confirming', () {
      final controller = PasscodeController();
      controller.addDigit('1');
      expect(controller.value.passcode, '1');
      controller.addDigit('2');
      expect(controller.value.passcode, '12');
    });

    test('entering 4 digits sets isConfirming to true', () {
      final controller = PasscodeController();
      controller.addDigit('1');
      controller.addDigit('2');
      controller.addDigit('3');
      controller.addDigit('4');
      expect(controller.value.passcode, '1234');
      expect(controller.value.isConfirming, true);
    });

    test('addDigit appends digits to confirmPasscode when confirming', () {
      final controller = PasscodeController();
      for (var i = 1; i <= 4; i++) {
        controller.addDigit(i.toString());
      }
      expect(controller.value.isConfirming, true);
      controller.addDigit('5');
      expect(controller.value.confirmPasscode, '5');
    });

    test('removeDigit removes last digit from passcode when not confirming', () {
      final controller = PasscodeController();
      controller.addDigit('1');
      controller.addDigit('2');
      controller.removeDigit();
      expect(controller.value.passcode, '1');
    });

    test('removeDigit removes from confirmPasscode when confirming', () {
      final controller = PasscodeController();
      for (var i = 1; i <= 4; i++) {
        controller.addDigit(i.toString());
      }
      controller.addDigit('5');
      controller.removeDigit();
      expect(controller.value.confirmPasscode, '');
      expect(controller.value.isConfirming, true);
    });

    test('removeDigit transitions back from isConfirming if confirmPasscode is empty', () {
      final controller = PasscodeController();
      for (var i = 1; i <= 4; i++) {
        controller.addDigit(i.toString());
      }
      expect(controller.value.isConfirming, true);
      controller.removeDigit();
      expect(controller.value.isConfirming, false);
      expect(controller.value.passcode, '123');
    });
  });
}
