import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum AppToastType { success, error, warning, deleteWithUndo }

class AppToast {
  static void show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? description,
    VoidCallback? onUndo,
    VoidCallback? onCompleted,
  }) {
    final l10n = AppLocalizations.of(context)!;

    toastification.show(
      context: context,
      type: _getToastType(type),
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      description: description != null ? Text(description) : null,
      closeButton: type == AppToastType.deleteWithUndo
          ? ToastCloseButton(
              showType: CloseButtonShowType.always,
              buttonBuilder: (context, onClose) {
                return GestureDetector(
                  onTap: () {
                    if (onUndo != null) onUndo();
                    onClose();
                  },
                  child: Text(l10n.undo, style: AppTextStyles.button),
                );
              },
            )
          : const ToastCloseButton(),
      callbacks: ToastificationCallbacks(
        onAutoCompleteCompleted: (item) {
          if (onCompleted != null) onCompleted();
        },
      ),
    );
  }

  static ToastificationType _getToastType(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return ToastificationType.success;
      case AppToastType.error:
        return ToastificationType.error;
      case AppToastType.warning:
      case AppToastType.deleteWithUndo:
        return ToastificationType.warning;
    }
  }
}
