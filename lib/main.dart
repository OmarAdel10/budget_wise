import 'dart:io';

import 'package:budget_wise/app_entry/view/initialization_loading_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/routes/routes.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/app_providers.dart';
import 'package:budget_wise/shared/app_theme.dart';
import 'package:budget_wise/shared/utils/background_tasks.dart';
import 'package:budget_wise/shared/utils/sms_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrapper());
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  final ValueNotifier<String> _statusNotifier = ValueNotifier(
    "Securing your financial vault...",
  );
  final ValueNotifier<bool> _isInitializedNotifier = ValueNotifier(false);

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // 1. MethodChannel (Milestone 1)
      const platform = MethodChannel('com.budget_wise/init');
      await platform.invokeMethod('onFlutterReady');
      _progressNotifier.value = 0.2;
      _statusNotifier.value = "Securing your financial vault...";

      // 2. Core Init (Milestone 2)
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        getApplicationDocumentsDirectory(),
        Firebase.initializeApp(),
      ]);

      _prefs = results[0] as SharedPreferences;
      final docsDir = results[1] as Directory;

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(docsDir.path),
      );
      _progressNotifier.value = 0.5;
      _statusNotifier.value = "Gathering your latest transactions...";

      // 3. Feature Init (Milestone 3 & 4)
      final bool isNotificationGranted =
          await NotificationRepository.isPermissionGranted();
      final bool isMicrophonePermissionGranted =
          await Permission.microphone.isGranted;

      final SmsService smsService = SmsService();
      await smsService.requestPermissions();
      smsService.initializeBackgroundHandler();
      _progressNotifier.value = 0.8;
      _statusNotifier.value = "Syncing with your budget goals...";

      await NotificationRepository.notificationInit();
      if (!isNotificationGranted) {
        await NotificationRepository.requestPermissions();
      }
      if (!isMicrophonePermissionGranted) {
        await Permission.microphone.request();
      }

      BackgroundTasks.initialize();
      BackgroundTasks.scheduleTasks();

      _progressNotifier.value = 1.0;
      _statusNotifier.value = "Ready to make smart moves!";

      await Future.delayed(const Duration(milliseconds: 500));
      _isInitializedNotifier.value = true;
    } catch (e) {
      debugPrint('Bootstrap Error: $e');
      _isInitializedNotifier.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitializedNotifier,
      builder: (context, isInitialized, child) {
        if (!isInitialized || _prefs == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: InitializationLoadingScreen(
              progressNotifier: _progressNotifier,
              statusNotifier: _statusNotifier,
            ),
          );
        }
        return AppProviders.initProviders(const BudgetWise(), _prefs!);
      },
    );
  }
}

class BudgetWise extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const BudgetWise({super.key});

  @override
  State<BudgetWise> createState() => _BudgetWiseState();
}

class _BudgetWiseState extends State<BudgetWise> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        String initialRoute = MainScreen.routeName;
        //! un-comment after redesign onBoradingScreens
        // if (!state.model.isOnboardingCompleted) {
        //   initialRoute = OnboardingScreen.routeName;
        // } else if (state.model.localAuthEnabled) {
        //   initialRoute = LocalAuthScreen.routeName;
        // }
        return ToastificationWrapper(
          child: MaterialApp(
            navigatorKey: BudgetWise.navigatorKey,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
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
            initialRoute: initialRoute,
          ),
        );
      },
    );
  }
}
