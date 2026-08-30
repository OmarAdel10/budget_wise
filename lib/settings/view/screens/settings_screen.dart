import 'package:budget_wise/buckets/view_model/buckets_view_model.dart';
import 'package:budget_wise/csv_export/view_model/csv_bloc.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/settings/view/widgets/tiles/accounts_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/categories_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/merchant_rules_list_tile.dart';
import 'package:budget_wise/settings/view/widgets/data_import_export_card.dart';
import 'package:budget_wise/settings/view/widgets/tiles/notification_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/tiles/preferences_tile.dart';
import 'package:budget_wise/settings/view/widgets/profile_header_section.dart';
import 'package:budget_wise/settings/view/widgets/tiles/security_settings_tile.dart';
import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/shared/utils/app_toast.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/utils/auth_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/link.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../../auth/view/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings-screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _handleLogout() {
    context.read<AuthBloc>().add(AuthEventSignOut());
    context.read<SettingsBloc>().add(SettingsEventLoggedOut());
    context.read<TransactionBloc>().clear();
    context.read<CategoryBloc>().clear();
    context.read<AccountBloc>().clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  void resetAll() {
    context.read<TransactionBloc>().clear();
    context.read<CategoryBloc>().clear();
    context.read<AccountBloc>().clear();
    context.read<BucketsBloc>().clear();
    context.read<SubscriptionBloc>().clear();
    context.read<SettingsBloc>().clear();
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    return BlocListener<CsvBloc, CsvState>(
      listener: (context, state) {
        if (state is CsvLoading) {
          AppToast.show(context, title: state.message, type: AppToastType.info);
        } else if (state is CsvExportSuccess) {
          AppToast.show(
            context,
            title: context.l10n.exportSuccess,
            type: AppToastType.success,
          );
        } else if (state is CsvImportSuccess) {
          AppToast.show(
            context,
            title: context.l10n.importSuccess(state.count),
            description: state.skipped > 0
                ? context.l10n.skippedDuplicates(state.skipped)
                : null,
            type: AppToastType.success,
          );
        } else if (state is CsvFailure) {
          AppToast.show(
            context,
            title: context.l10n.operationFailed,
            description: state.message,
            type: AppToastType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.primaryBackground,
                elevation: 0,
                automaticallyImplyLeading: false,
                pinned: true,
                centerTitle: true,
                title: Text(
                  context.l10n.navSettings,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (user != null)
                      ProfileHeaderSection(
                        user: user,
                        authRepository: authRepository,
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            LoginScreen.routeName,
                            arguments: {
                              'loginRouting': LoginRouting.fromSettings,
                            },
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          child: Text(
                            context.l10n.login,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // App Settings Section
                    Text(context.l10n.appSettings, style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Column(
                        children: [
                          const PreferencesTile(),
                          const CategoriesTile(),
                          const AccountsTile(),
                          const MerchantRulesListTile(),
                          const SecuritySettingsTile(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Notification Settings Section
                    Text(
                      context.l10n.notificationSettings,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Column(
                        children: [const NotificationSettingsTile()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Data Management Section
                    Text('Data Management', style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    const DataImportExportCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Delete Account - implement later (only show when the user is logged in)
                    // GestureDetector(
                    //   onTap: resetAll,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       const Icon(
                    //         PhosphorIconsBold.trash,
                    //         color: AppColors.danger,
                    //         size: 14,
                    //       ),
                    //       const SizedBox(width: AppSpacing.sm),
                    //       Text(
                    //         'Delete Account',
                    //         style: AppTextStyles.bodyMedium.copyWith(
                    //           color: AppColors.danger,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: AppSpacing.md),

                    // About Section
                    Text(context.l10n.about, style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.appVersion,
                                style: AppTextStyles.bodyLarge,
                              ),
                              Text(
                                AppConstants.appVersion,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Link(
                                uri: AppConstants.emailUri,
                                target: LinkTarget.blank,
                                builder: (context, followLink) => IconButton(
                                  icon: const Icon(
                                    PhosphorIconsRegular.envelope,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: followLink,
                                ),
                              ),
                              Link(
                                uri: AppConstants.linkedInUri,
                                target: LinkTarget.blank,
                                builder: (context, followLink) => IconButton(
                                  icon: const Icon(
                                    PhosphorIconsRegular.linkedinLogo,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: followLink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Align(
                            alignment: AlignmentGeometry.bottomEnd,
                            child: Text(
                              context.l10n.madeByOmarAdel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    if (user != null)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _handleLogout,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          child: Text(
                            context.l10n.logout,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
