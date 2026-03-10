import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/home/view/widgets/home_summary_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeFlexibleHeader extends StatefulWidget {
  final ScrollController scrollController;
  const HomeFlexibleHeader({super.key, required this.scrollController});

  @override
  State<HomeFlexibleHeader> createState() => _HomeFlexibleHeaderState();
}

class _HomeFlexibleHeaderState extends State<HomeFlexibleHeader> {
  final ValueNotifier<double> _scrollPercentage = ValueNotifier<double>(1.0);

  @override
  void dispose() {
    _scrollPercentage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expandedHeight = MediaQuery.sizeOf(context).height * 0.15;

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          previous.currencySymbol != current.currencySymbol,
      builder: (context, settingsState) {
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.model.totalIncome != current.model.totalIncome ||
              previous.model.totalExpenses != current.model.totalExpenses,
          builder: (context, homeState) {
            return SliverAppBar(
              pinned: true,
              expandedHeight: expandedHeight,
              backgroundColor: AppColors.primaryBackground,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double percentage =
                      ((constraints.biggest.height - kToolbarHeight) /
                              (expandedHeight - kToolbarHeight))
                          .clamp(0.0, 1.0);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _scrollPercentage.value != percentage) {
                      _scrollPercentage.value = percentage;
                    }
                  });

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                    expandedTitleScale: 1.0,
                    background: ValueListenableBuilder<double>(
                      valueListenable: _scrollPercentage,
                      builder: (context, val, child) {
                        return RepaintBoundary(
                          child: Opacity(opacity: val, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: HomeSummaryRow(
                          totalIncome: homeState.model.totalIncome,
                          totalExpenses: homeState.model.totalExpenses,
                          currencySymbol: settingsState.currencySymbol,
                          isCollapsed: false,
                        ),
                      ),
                    ),
                    title: ValueListenableBuilder<double>(
                      valueListenable: _scrollPercentage,
                      builder: (context, val, child) {
                        return RepaintBoundary(
                          child: Opacity(
                            opacity: (1.0 - val).clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          widget.scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: HomeSummaryRow(
                            totalIncome: homeState.model.totalIncome,
                            totalExpenses: homeState.model.totalExpenses,
                            currencySymbol: settingsState.currencySymbol,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
