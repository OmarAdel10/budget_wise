import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencySettingsTile extends StatelessWidget {
  final ValueNotifier<String?> selectedCurrencyNotifier;
  const CurrencySettingsTile({super.key, required this.selectedCurrencyNotifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsTile(
      icon: PhosphorIconsRegular.currencyBtc,
      title: l10n.defaultCurrency,
      trailing: CurrencyPrefix(
        selectedCurrencyNotifier: selectedCurrencyNotifier,
        isSettingsTile: true,
      ),
    );
  }
}
