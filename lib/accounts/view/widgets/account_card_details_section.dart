import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/view/widgets/credit_card_display.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class AccountCardDetailsSection extends StatelessWidget {
  final AccountModel account;

  const AccountCardDetailsSection({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    if (account.accountType != AccountType.card) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: CreditCardDisplay(
          bankName: account.cardBankName ?? '',
          cardHolderName: account.cardHolderName ?? '',
          cardNumber: account.cardNumber ?? '',
          expiryDate: account.cardExpiryDate ?? '',
          cardType: account.cardBrand ?? CardBrand.mastercard,
        ),
      ),
    );
  }
}
