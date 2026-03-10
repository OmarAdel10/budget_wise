import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/view/widgets/credit_card_display.dart';
import 'package:flutter/material.dart';

class CreditCardPreview extends StatelessWidget {
  final ValueNotifier<String?> bankNameNotifier;
  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController expiryController;
  final ValueNotifier<CardBrand> cardTypeNotifier;
  final String? currentUserDisplayName;

  const CreditCardPreview({
    super.key,
    required this.bankNameNotifier,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.expiryController,
    required this.cardTypeNotifier,
    this.currentUserDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: Listenable.merge([
          bankNameNotifier,
          cardNumberController,
          cardHolderController,
          expiryController,
          cardTypeNotifier,
        ]),
        builder: (context, _) {
          return CreditCardDisplay(
            bankName: bankNameNotifier.value ?? '',
            cardNumber: cardNumberController.text,
            cardHolderName:
                currentUserDisplayName ?? cardHolderController.text.trim(),
            expiryDate: expiryController.text,
            cardType: cardTypeNotifier.value,
          );
        },
      ),
    );
  }
}
