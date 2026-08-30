import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// External search controller. If provided, the app bar uses this instead of
  /// creating its own. Useful when the parent wants to control search state
  /// (e.g., via [SearchService]).
  final TextEditingController? searchController;

  /// External focus node for the search field. If provided, the app bar uses
  /// this instead of creating its own.
  final FocusNode? searchFocusNode;

  const HomeAppBar({super.key, this.searchController, this.searchFocusNode});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late final AnimationController _animationController;
  late final Animation<double> _searchAnimation;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isLocalController = false;
  bool _isLocalFocusNode = false;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.searchController != null) {
      _searchController = widget.searchController!;
    } else {
      _searchController = TextEditingController();
      _isLocalController = true;
    }

    if (widget.searchFocusNode != null) {
      _searchFocusNode = widget.searchFocusNode!;
    } else {
      _searchFocusNode = FocusNode();
      _isLocalFocusNode = true;
    }

    _controllerListener = () {
      if (mounted) setState(() {});
    };
    _searchController.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isLocalController) {
      _searchController.dispose();
    } else if (_controllerListener != null) {
      _searchController.removeListener(_controllerListener!);
    }
    if (_isLocalFocusNode) _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_isSearching) {
      _searchFocusNode.unfocus();
      _searchController.clear();
      _animationController.reverse();
    } else {
      _animationController.forward().then((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      centerTitle: true,
      title: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          final double value = _searchAnimation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Title text — fades out as search expands
              Opacity(
                opacity: 1.0 - value,
                child: Text(
                  context.l10n.appTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Search field — fades in and slides in from the right
              Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(30.0 * (1.0 - value), 0.0),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchTransactions,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.secondaryBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryAccent,
                            width: 1,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.xCircle,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: PhosphorIcon(
              _isSearching
                  ? PhosphorIconsBold.x
                  : PhosphorIconsBold.magnifyingGlass,
              key: ValueKey(_isSearching),
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
