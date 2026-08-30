import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:budget_wise/main.dart';

enum AppToastType { success, error, warning, info, deleteWithUndo }

class AppToast {
  static void show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? description,
    VoidCallback? onUndo,
    VoidCallback? onCompleted,
  }) {
    // Capture the undo label from the provided context (still valid for strings)
    final String undoLabel = context.l10n.undo;
    // Use a stable root context (navigator key) to avoid deactivated widget errors
    final BuildContext safeContext =
        BudgetWise.navigatorKey.currentContext ?? context;
    toastification.show(
      context: safeContext,
      type: _getToastType(type),
      alignment: Alignment.topCenter,
      backgroundColor: AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(color: AppColors.borderColor),
      boxShadow: [AppBoxShadow()],
      dragToClose: true,
      dismissDirection: DismissDirection.none,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      description: description != null
          ? Text(description, style: AppTextStyles.bodySmall)
          : null,
      closeButton: type == AppToastType.deleteWithUndo
          ? ToastCloseButton(
              showType: CloseButtonShowType.always,
              buttonBuilder: (_, onClose) {
                return GestureDetector(
                  onTap: () {
                    if (onUndo != null) onUndo();
                    onClose();
                  },
                  child: Text(
                    undoLabel,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            )
          : ToastCloseButton(showType: CloseButtonShowType.none),
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
      case AppToastType.info:
        return ToastificationType.info;
      case AppToastType.warning:
      case AppToastType.deleteWithUndo:
        return ToastificationType.warning;
    }
  }
}
