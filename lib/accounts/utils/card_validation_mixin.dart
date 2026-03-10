import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:flutter/foundation.dart';

mixin CardValidationMixin {
  final ValueNotifier<bool> isCardValidNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isExpiryValidNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<CardBrand> selectedCardBrandNotifier =
      ValueNotifier<CardBrand>(CardBrand.mastercard);

  void determineCardType(String cleanedCardNumber) {
    if (cleanedCardNumber.isNotEmpty) {
      if (cleanedCardNumber.startsWith('4')) {
        selectedCardBrandNotifier.value = CardBrand.visa;
      } else if (RegExp(r'^5[1-5]').hasMatch(cleanedCardNumber) ||
          RegExp(
            r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[01][0-9]|720)',
          ).hasMatch(cleanedCardNumber)) {
        selectedCardBrandNotifier.value = CardBrand.mastercard;
      } else if (cleanedCardNumber.startsWith('5078') ||
          cleanedCardNumber.startsWith('9828')) {
        selectedCardBrandNotifier.value = CardBrand.mezza;
      }
    }
  }

  bool checkCardNumberValidity(String cardNumber) {
    final cleanedNumber = cardNumber.replaceAll(' ', '');
    if (cleanedNumber.length != 16) return false;

    int sum = 0;
    for (int i = 0; i < cleanedNumber.length; i++) {
      int digit = int.parse(cleanedNumber[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0;
  }

  void validateCardNumber(String cardNumber) {
    determineCardType(cardNumber);
    isCardValidNotifier.value = checkCardNumberValidity(cardNumber);
  }

  bool checkExpiryDateValidity(String input) {
    if (input.length != 5) return false;
    final parts = input.split('/');
    if (parts.length != 2) return false;

    final int? month = int.tryParse(parts[0]);
    final int? year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      return false;
    }

    final now = DateTime.now();
    final int currentYear = now.year % 100;
    final int currentMonth = now.month;
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }
    return true;
  }

  void validateExpiryDate(String input) {
    isExpiryValidNotifier.value = checkExpiryDateValidity(input);
  }

  void disposeCardValidationNotifiers() {
    isCardValidNotifier.dispose();
    isExpiryValidNotifier.dispose();
    selectedCardBrandNotifier.dispose();
  }
}
