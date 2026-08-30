import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
