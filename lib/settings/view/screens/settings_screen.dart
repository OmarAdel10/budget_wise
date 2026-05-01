import 'package:budget_wise/csv_export/view_model/csv_bloc.dart';
import 'package:budget_wise/settings/view/widgets/data_import_export_card.dart';
import 'package:budget_wise/settings/view/widgets/language_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/notification_settings_tile.dart';
import 'package:budget_wise/settings/view/widgets/profile_header_section.dart';
import 'package:budget_wise/settings/view/widgets/security_settings_tile.dart';
import 'package:budget_wise/shared/constants/app_constants.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view/widgets/bank_margin_tile.dart';
import 'package:budget_wise/settings/view/widgets/currency_settings_tile.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/utils/auth_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:toastification/toastification.dart';
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
  late final ValueNotifier<String?> selectedCurrencyNotifier;

  @override
  void initState() {
    super.initState();
    final initialCurrency = context
        .read<SettingsBloc>()
        .state
        .model
        .defaultCurrency;
    selectedCurrencyNotifier = ValueNotifier(initialCurrency);
  }

  @override
  void dispose() {
    selectedCurrencyNotifier.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CsvBloc, CsvState>(
      listener: (context, state) {
        if (state is CsvLoading) {
          toastification.show(
            context: context,
            title: Text(state.message),
            type: ToastificationType.info,
            autoCloseDuration: const Duration(seconds: 2),
          );
        } else if (state is CsvExportSuccess) {
          toastification.show(
            context: context,
            title: const Text('Export completed successfully.'),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is CsvImportSuccess) {
          toastification.show(
            context: context,
            title: Text('Imported ${state.count} items successfully!'),
            description: state.skipped > 0
                ? Text('Skipped ${state.skipped} duplicate rows.')
                : null,
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 4),
          );
        } else if (state is CsvFailure) {
          toastification.show(
            context: context,
            title: const Text('Operation Failed'),
            description: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 5),
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
                  l10n.navSettings,
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
                            l10n.login,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // App Settings Section
                    Text(l10n.appSettings, style: AppTextStyles.heading3),
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
                          const SecuritySettingsTile(),
                          const LanguageSettingsTile(),
                          CurrencySettingsTile(
                            selectedCurrencyNotifier: selectedCurrencyNotifier,
                          ),
                          const BankMarginTile(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Notification Settings Section
                    Text(
                      l10n.notificationSettings,
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
                    const SizedBox(height: AppSpacing.xl),

                    // About Section
                    Text(l10n.about, style: AppTextStyles.heading3),
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
                                l10n.appVersion,
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
                              l10n.madeByOmarAdel,
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
                            l10n.logout,
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
