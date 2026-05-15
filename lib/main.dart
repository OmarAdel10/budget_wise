import 'dart:developer';
import 'dart:io';
import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/routes/routes.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/sms_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:budget_wise/shared/app_theme.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:budget_wise/shared/app_providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_wise/shared/utils/background_tasks.dart';

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
  bool _initialized = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
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

      const platform = MethodChannel('com.budget_wise/init');
      await platform.invokeMethod('onFlutterReady');

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      debugPrint('Bootstrap Error: $e');
      if (mounted) setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _prefs == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: Container(),
      );
    }

    return AppProviders.initProviders(const BudgetWise(), _prefs!);
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
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final bool isNotificationGranted =
        await NotificationRepository.isPermissionGranted();
    final bool isMicrophonePermissionGranted = await Permission.microphone.isGranted;
    await Future.wait([
      NotificationRepository.notificationInit(),
      if (!isNotificationGranted) NotificationRepository.requestPermissions(),
      if (!isMicrophonePermissionGranted) Permission.microphone.request(),
    ]);

    SmsService().initializeBackgroundHandler();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BackgroundTasks.initialize();
        BackgroundTasks.scheduleTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        String initialRoute = MainScreen.routeName;
        if (!state.model.isOnboardingCompleted) {
          initialRoute = OnboardingScreen.routeName;
        } else if (state.model.localAuthEnabled) {
          initialRoute = LocalAuthScreen.routeName;
        }
        return MaterialApp(
          navigatorKey: BudgetWise.navigatorKey,
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
          initialRoute: initialRoute,
        );
      },
    );
  }
}
