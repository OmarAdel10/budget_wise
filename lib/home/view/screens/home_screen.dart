import 'package:budget_wise/home/view/widgets/home_recent_transactions_header.dart';
import 'package:budget_wise/home/view/widgets/home_static_header.dart';
import 'package:budget_wise/shared/data/services/search_service.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/shared/widgets/custom_button.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_bottom_sheet.dart';
import 'package:budget_wise/transaction/view/widgets/pending_sms_bottom_sheet.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/home/view/widgets/home_app_bar.dart';
import 'package:budget_wise/home/view/widgets/home_recent_transactions.dart';
import 'package:budget_wise/home/view_model/home_event.dart';
import 'package:budget_wise/home/view_model/home_state.dart';
import 'package:budget_wise/home/view_model/home_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/widgets/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../settings/view_model/settings_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<DateTime> _selectedMonthNotifier;
  late final SearchService<TransactionModel> _searchService;
  late final FocusNode _searchFocusNode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedMonthNotifier = ValueNotifier<DateTime>(
      DateTime(DateTime.now().year, DateTime.now().month),
    );
    _searchFocusNode = FocusNode();
    _searchService = SearchService<TransactionModel>(
      searchFieldsExtractor: (tx) {
        return [
          if (tx.description != null) tx.description!,
          if (tx.transactionNotes != null) tx.transactionNotes!,
          tx.transactionAmount.toString(),
          tx.transactionCurrency,
          tx.categoryId,
          tx.accountId,
        ];
      },
    );
    final savedFilterId = context
        .read<SettingsBloc>()
        .state
        .model
        .homeFilterAccountId;
    context.read<HomeBloc>().add(
      HomeEventLoadAllData(
        _selectedMonthNotifier.value,
        accountId: savedFilterId,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedMonthNotifier.dispose();
    _searchService.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _monthChange(int monthOffset) {
    final current = _selectedMonthNotifier.value;
    _selectedMonthNotifier.value = DateTime(
      current.year,
      current.month + monthOffset,
    );
    context.read<HomeBloc>().add(
      HomeEventLoadAllData(_selectedMonthNotifier.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.currencySymbol,
    );
    // final isVoiceMode =
    //     settingsState.model.transactionInputMode == TransactionInputMode.voice;

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          current is HomeStateSuccess &&
          previous.model.transactions != current.model.transactions,
      listener: (context, state) {
        _searchService.updateSource(state.model.transactions);
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: HomeAppBar(
          searchController: _searchService.searchController,
          searchFocusNode: _searchFocusNode,
        ),
        body: Column(
          children: [
            ValueListenableBuilder<DateTime>(
              valueListenable: _selectedMonthNotifier,
              builder: (context, date, _) {
                return MonthSelector(
                  selectedMonth: date,
                  onPrevious: () => _monthChange(-1),
                  onNext: () => _monthChange(1),
                );
              },
            ),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) => HomeStaticHeader(
                totalIncome: state.model.totalIncome,
                totalExpenses: state.model.totalExpenses,
                currencySymbol: currencySymbol,
              ),
            ),
            BlocSelector<
              TransactionBloc,
              TransactionState,
              List<SmsDraftModel>
            >(
              selector: (state) => state.pendingSmsTransactions,
              builder: (context, pendingDrafts) {
                if (pendingDrafts.isEmpty) {
                  return const SizedBox(height: AppSpacing.md);
                }
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [AppBoxShadow()],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const GenericIconContainer(
                            icon: PhosphorIconsBold.clockClockwise,
                            color: AppColors.textSecondary,
                            backgroundOpacity: 0,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.pendingReview(
                                  pendingDrafts.length,
                                ),
                                style: AppTextStyles.heading3,
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                context.l10n.transactionsRequireReviewing,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CustomButton(
                        text: context.l10n.review,
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const PendingSmsBottomSheet(),
                        ),
                        rightIcon: PhosphorIcon(PhosphorIconsBold.arrowRight),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        borderRadius: AppSpacing.radiusMd,
                        borderColor: AppColors.borderColor.withValues(
                          alpha: 0.4,
                        ),
                        borderWidth: 1.5,
                      ),
                    ],
                  ),
                );
              },
            ),
            const HomeRecentTransactionsHeader(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchService.queryNotifier,
                builder: (context, query, _) {
                  return ValueListenableBuilder<List<TransactionModel>>(
                    valueListenable: _searchService.filteredListNotifier,
                    builder: (context, filtered, _) {
                      return HomeRecentTransactions(
                        filteredTransactions: query.isNotEmpty
                            ? filtered
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "home_fab",
          tooltip: context.l10n.addTransactionTitle,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTransactionBottomSheet(),
            );
          },
          backgroundColor: AppColors.primaryAccent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(AppSpacing.radiusLg),
            side: BorderSide(color: AppColors.borderColor, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
        ),
      ),
    );
  }
}
