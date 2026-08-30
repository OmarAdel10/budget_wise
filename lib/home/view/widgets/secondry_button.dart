import 'dart:async';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/data/models/transaction_input_mode.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SecondryButton extends StatefulWidget {
  const SecondryButton({super.key});

  @override
  State<SecondryButton> createState() => _SecondryButtonState();
}

class _SecondryButtonState extends State<SecondryButton> {
  final ValueNotifier<String> _timerText = ValueNotifier<String>("00:00");
  final isVoiceOn = ValueNotifier<bool>(false);
  final _blinkingNotifier = ValueNotifier<bool>(true);
  Timer? _timer;
  int _seconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _timerText.dispose();
    isVoiceOn.dispose();
    _blinkingNotifier.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      _blinkingNotifier.value = !_blinkingNotifier.value;
      final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_seconds % 60).toString().padLeft(2, '0');
      _timerText.value = "$minutes:$seconds";
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionMode = context.select<SettingsBloc, TransactionInputMode>(
      (bloc) => bloc.state.model.transactionInputMode,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: isVoiceOn,
      builder: (context, isVoice, child) {
        if (isVoice) {
          return _VoiceActiveButton(
            timerText: _timerText,
            blinkingNotifier: _blinkingNotifier,
            onTap: () {
              _timer?.cancel();
              isVoiceOn.value = false;
            },
          );
        }
        return _IdleSecondaryButton(
          transactionMode: transactionMode,
          onTap: () {
            if (transactionMode == TransactionInputMode.manual) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useSafeArea: true,
                builder: (context) => const AddTransactionBottomSheet(),
              );
            } else if (transactionMode == TransactionInputMode.voice) {
              isVoiceOn.value = true;
              _seconds = 0;
              _timerText.value = "00:00";
              _startTimer();
            }
          },
        );
      },
    );
  }
}

class _VoiceActiveButton extends StatelessWidget {
  final ValueNotifier<String> timerText;
  final ValueNotifier<bool> blinkingNotifier;
  final VoidCallback onTap;

  const _VoiceActiveButton({
    required this.timerText,
    required this.blinkingNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.3),
          border: Border.all(color: AppColors.danger, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [AppBoxShadow()],
        ),
        child: Row(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: timerText,
              builder: (context, text, child) => Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            RepaintBoundary(
              child: ValueListenableBuilder<bool>(
                valueListenable: blinkingNotifier,
                builder: (context, isBlinking, child) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isBlinking ? 1 : 0,
                  child: Icon(
                    PhosphorIconsBold.microphone,
                    color: AppColors.danger,
                    size: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleSecondaryButton extends StatelessWidget {
  final TransactionInputMode transactionMode;
  final VoidCallback onTap;

  const _IdleSecondaryButton({
    required this.transactionMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [AppBoxShadow()],
        ),
        child: Row(
          children: [
            Text(
              transactionMode == TransactionInputMode.voice
                  ? context.l10n.voiceNote
                  : context.l10n.addTransactionTitle,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(width: AppSpacing.sm - 2),
            Icon(
              transactionMode == TransactionInputMode.voice
                  ? PhosphorIconsBold.microphone
                  : PhosphorIconsBold.plusCircle,
              size: 11,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
