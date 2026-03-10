import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CreditCardDisplay extends StatelessWidget {
  final String bankName;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final CardBrand cardType;

  const CreditCardDisplay({
    super.key,
    required this.bankName,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.06,
      child: CreditCardWidget(
        cardNumber: cardNumber.isEmpty ? '0000 0000 0000 0000' : cardNumber,
        expiryDate: expiryDate.isEmpty ? 'MM/YY' : expiryDate,
        cardHolderName: cardHolderName.isEmpty
            ? AppLocalizations.of(context)!.cardHolder
            : cardHolderName,
        cardType: _getCardType(cardType),
        customCardTypeIcons: <CustomCardTypeIcon>[
          CustomCardTypeIcon(
            cardType: CardType.otherBrand,
            cardImage: Image.asset(
              'assets/images/mezza.png',
              height: 48,
              width: 48 * 1.3,
              fit: BoxFit.fill,
            ),
          ),
        ],
        isChipVisible: true,
        bankName: bankName,
        isHolderNameVisible: true,
        obscureCardNumber: true,
        cvvCode: '***',
        showBackView: false,
        onCreditCardWidgetChange: (_) {},
        glassmorphismConfig: Glassmorphism.defaultConfig(),
        isSwipeGestureEnabled: true,
        obscureInitialCardNumber: true,
      ),
    );
  }

  CardType _getCardType(CardBrand brand) {
    switch (brand) {
      case CardBrand.visa:
        return CardType.visa;
      case CardBrand.mastercard:
        return CardType.mastercard;
      case CardBrand.mezza:
        return CardType.otherBrand;
    }
  }
}
