import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/shared/routes.dart';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/sms_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:budget_wise/shared/app_theme.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:budget_wise/shared/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await Future.wait([
    Firebase.initializeApp(),
    NotificationRepository.notificationInit(),
  ]);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Early registration of the background SMS handler to ensure it works even when killed.
  SmsService().initializeBackgroundHandler();

  runApp(AppProviders.initProviders(const BudgetWise(), prefs));
}

class BudgetWise extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const BudgetWise({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          locale: Locale(state.model.language),
          onGenerateRoute: Routes.onGenerateRoutes(context),
          initialRoute:
              context.read<SettingsBloc>().state.model.isOnboardingCompleted
              ? context.read<SettingsBloc>().state.model.localAuthEnabled
                    ? LocalAuthScreen.routeName
                    : MainScreen.routeName
              : OnboardingScreen.routeName,
        );
      },
    );
  }
}
