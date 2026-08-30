import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TransactionType selectedType;
  final bool isTitle;

  const DescriptionField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedType,
    this.isTitle = false,
  });

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _showSuggestionsNotifier = ValueNotifier(false);
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
    _showSuggestionsNotifier.addListener(_syncOverlay);
    _suggestionsNotifier.addListener(_syncOverlay);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _showSuggestionsNotifier.removeListener(_syncOverlay);
    _suggestionsNotifier.removeListener(_syncOverlay);
    _closeOverlay();
    _suggestionsNotifier.dispose();
    _showSuggestionsNotifier.dispose();
    super.dispose();
  }

  void _syncOverlay() {
    if (!mounted) return;
    final shouldShow =
        _showSuggestionsNotifier.value && _suggestionsNotifier.value.isNotEmpty;
    if (shouldShow) {
      if (_overlayEntry == null) {
        _showOverlay();
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _closeOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _dismissSuggestions() {
    _showSuggestionsNotifier.value = false;
  }

  void _onSuggestionSelected(String selected) {
    widget.controller.text = selected;
    _suggestionsNotifier.value = [];
    _showSuggestionsNotifier.value = false;
    widget.focusNode.unfocus();
  }

  double _anchorWidth() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? MediaQuery.sizeOf(context).width;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        final suggestions = _suggestionsNotifier.value;
        final width = _anchorWidth();

        return Stack(
          children: [
            GestureDetector(
              onTap: _dismissSuggestions,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: _DescriptionSuggestionsContent(
                  width: width,
                  suggestions: suggestions,
                  onSuggestionSelected: _onSuggestionSelected,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTextChanged() {
    if (!mounted) return;
    final searchText = widget.controller.text.trim();
    if (searchText.isEmpty) {
      _suggestionsNotifier.value = [];
      _showSuggestionsNotifier.value = false;
      return;
    }

    final allDescriptions = context
        .read<TransactionBloc>()
        .state
        .transactionsList
        .where((t) => t.type == widget.selectedType)
        .map((t) => t.description ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();

    final filteredSuggestions = allDescriptions
        .where((desc) => desc.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    _suggestionsNotifier.value = filteredSuggestions;
    _showSuggestionsNotifier.value =
        filteredSuggestions.isNotEmpty && widget.focusNode.hasFocus;
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (!widget.focusNode.hasFocus) {
      _showSuggestionsNotifier.value = false;
    } else {
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptionHint = widget.selectedType == TransactionType.income
        ? context.l10n.incomeHint
        : context.l10n.expenseHint;

    return CompositedTransformTarget(
      key: _fieldKey,
      link: _layerLink,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showSuggestionsNotifier,
        builder: (context, showSuggestions, child) {
          return CustomTextField(
            label: widget.isTitle
                ? context.l10n.titleLabel
                : context.l10n.descriptionLabel,
            hintText: descriptionHint,
            controller: widget.controller,
            focusNode: widget.focusNode,
            shouldUnfocusOnTapOutside: !showSuggestions,
            hasOriginalInputDecoration: false,
          );
        },
      ),
    );
  }
}

class _DescriptionSuggestionsContent extends StatelessWidget {
  final double width;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionSelected;

  const _DescriptionSuggestionsContent({
    required this.width,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: MediaQuery.sizeOf(context).height * 0.2,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: [AppBoxShadow()],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          final title = suggestions[index];
          return ListTile(
            minTileHeight: 0,
            minVerticalPadding: 10,
            title: Text(title, style: AppTextStyles.bodyMedium),
            onTap: () => onSuggestionSelected(title),
          );
        },
        separatorBuilder: (_, _) => const Divider(color: AppColors.borderColor),
        itemCount: suggestions.length,
      ),
    );
  }
}
