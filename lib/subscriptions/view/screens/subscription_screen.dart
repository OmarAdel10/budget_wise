import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/subscriptions/view/screens/add_subscription_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_card.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_empty_state.dart';
import 'package:budget_wise/subscriptions/view/widgets/subscription_summary_header.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubscriptionScreen extends StatelessWidget {
  static const routeName = '/subscriptions';

  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.subscriptions,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        buildWhen: (previous, current) =>
            previous.subscriptions != current.subscriptions ||
            previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.isLoading && state.subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.subscriptions.isEmpty) {
            return const SubscriptionEmptyState();
          }

          return CustomScrollView(
            slivers: [
              const SubscriptionSummaryHeader(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subscription = state.subscriptions[index];
                    return SubscriptionCard(
                      subscription: subscription,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SubscriptionDetailsScreen.routeName,
                          arguments: {'subscriptionModel': subscription},
                        );
                      },
                    );
                  }, childCount: state.subscriptions.length),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ), // Space for FAB
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddSubscriptionScreen.routeName);
        },
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textInverse,
        child: const Icon(PhosphorIconsBold.plus, color: AppColors.textPrimary),
      ),
    );
  }
}
