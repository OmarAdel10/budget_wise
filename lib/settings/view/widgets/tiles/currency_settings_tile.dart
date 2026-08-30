import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view/widgets/settings_tile.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/widgets/currency_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CurrencySettingsTile extends StatefulWidget {
  const CurrencySettingsTile({
    super.key,
    // required this.selectedCurrencyNotifier,
  });

  @override
  State<CurrencySettingsTile> createState() => _CurrencySettingsTileState();
}

class _CurrencySettingsTileState extends State<CurrencySettingsTile> {
  late final ValueNotifier<String> selectedCurrencyNotifier;

  @override
  void initState() {
    super.initState();
    final initialCurrency = context
        .read<SettingsBloc>()
        .state
        .model
        .defaultCurrency;
    selectedCurrencyNotifier = ValueNotifier(initialCurrency);
  }

  @override
  void dispose() {
    selectedCurrencyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => showModalBottomSheet(
      //   context: context,
      //   useSafeArea: true,
      //   backgroundColor: Colors.transparent,
      //   builder: (context) => CurrencyPickerBottomSheet(
      //     selectedCurrency: selectedCurrencyNotifier.value,
      //     onCurrencySelected: (currency) {
      //       selectedCurrencyNotifier.value = currency;
      //       context.read<SettingsBloc>().add(
      //         SettingsEventUpdateDefaultCurrency(
      //           newDefaultCurrency: selectedCurrencyNotifier.value,
      //         ),
      //       );
      //     },
      //   ),
      // ),
      onTap: () => Navigator.of(context).push(
        BottomSheetService.pageRoute(
          child: (context) => CurrencyPickerBottomSheet(
            selectedCurrency: selectedCurrencyNotifier.value,
            onCurrencySelected: (currency) {
              selectedCurrencyNotifier.value = currency;
              context.read<SettingsBloc>().add(
                SettingsEventUpdateDefaultCurrency(
                  newDefaultCurrency: selectedCurrencyNotifier.value,
                ),
              );
            },
          ),
        ),
      ),
      child: SettingsTile(
        icon: PhosphorIconsRegular.currencyBtc,
        title: context.l10n.defaultCurrency,
        showDivider: true,
        hasPadding: true,
        paddingVertical: AppSpacing.md,
        trailing: Row(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: selectedCurrencyNotifier,
              builder: (context, value, child) {
                return Text(value, style: AppTextStyles.bodyMedium);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
