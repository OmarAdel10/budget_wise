import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BottomSheetService {
  static Route pageRoute({
    required Widget Function(BuildContext context) child,
    Duration transitionDuration = const Duration(milliseconds: 600),
    Curve curves = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child(context),
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        Curve curve = curves;

        final tween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: curve));

        final offsetTransition = animation.drive(tween);

        return SlideTransition(position: offsetTransition, child: child);
      },
    );
  }

  static Widget header({
    required String title,
    void Function()? onTap,
    bool hasPadding = false,
    EdgeInsets padding = const EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: AppSpacing.lg,
    ),
    bool isRoot = false,
    bool hasDrag = false,
    List<Widget>? actions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        isRoot || hasDrag ? const DragHandle() : const SizedBox.shrink(),
        Padding(
          padding: hasPadding ? padding : EdgeInsets.zero,
          child: _BottomSheetHeader(
            title: title,
            onTap: onTap,
            isRoot: isRoot,
            isXIcon: hasDrag,
            actions: actions,
          ),
        ),
      ],
    );
  }

  static Widget searchBar({
    required String hintText,
    required TextEditingController controller,
  }) {
    return SearchBar(
      hintText: hintText,
      hintStyle: WidgetStatePropertyAll(
        AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
      textStyle: WidgetStatePropertyAll(
        AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
      keyboardType: TextInputType.text,
      leading: Icon(
        PhosphorIconsRegular.magnifyingGlass,
        color: AppColors.textSecondary,
        size: 20,
      ),
      textInputAction: TextInputAction.search,
      controller: controller,
      padding: WidgetStatePropertyAll(
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      constraints: BoxConstraints(),
      onTapOutside: (event) => FocusNode().unfocus(),
    );
  }

  static Widget label({required String labelText}) {
    return Text(labelText, style: AppTextStyles.bodyMedium);
  }

  static Widget headerWithSearch({
    required String headerTitle,
    required String searchHintText,
    void Function()? onLeadingPressed,
    required TextEditingController searchController,
    bool isRoot = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        isRoot ? const DragHandle() : const SizedBox.shrink(),
        header(title: headerTitle, isRoot: isRoot, onTap: onLeadingPressed),
        const SizedBox(height: AppSpacing.lg),
        searchBar(hintText: searchHintText, controller: searchController),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final bool isRoot;
  final bool isXIcon;
  final List<Widget>? actions;
  const _BottomSheetHeader({
    required this.title,
    this.onTap,
    this.isRoot = false,
    this.isXIcon = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Positioned(
          left: 0,
          child: GestureDetector(
            onTap:
                onTap ??
                () => Navigator.of(context, rootNavigator: isRoot).pop(),
            child: Icon(
              isRoot || isXIcon
                  ? PhosphorIconsRegular.x
                  : PhosphorIconsRegular.caretLeft,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        Text(title, style: AppTextStyles.heading3),
        actions != null
            ? Positioned(
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
