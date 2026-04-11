import 'package:budget_wise/auth/view/screens/local_auth_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/main_navigation/view/screens/main_screen.dart';
import 'package:budget_wise/onboarding/view/screens/onboarding_screen.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A professional, localized, and high-performance animated splash screen.
///
/// This screen takes over from the native splash screen and provides
/// branding animations before redirecting the user based on their state.
class SplashScreen extends StatefulWidget {
  /// The route name for the splash screen.
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Image _logoImage;

  @override
  void initState() {
    super.initState();
    _logoImage = Image.asset('assets/images/app_icon.png');
    _navigateToNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Optimization: Precache image to prevent flicker when taking over from native splash
    precacheImage(_logoImage.image, context);
  }

  /// Redirects the user based on their onboarding and auth state after a delay.
  Future<void> _navigateToNext() async {
    // 2.5s duration for branding impact
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final settingsState = context.read<SettingsBloc>().state;
    final String nextRoute;

    if (!settingsState.model.isOnboardingCompleted) {
      nextRoute = OnboardingScreen.routeName;
    } else if (settingsState.model.localAuthEnabled) {
      nextRoute = LocalAuthScreen.routeName;
    } else {
      nextRoute = MainScreen.routeName;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _logoImage,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.0, 1.0),
                  duration: 1200.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 1200.ms),

            const SizedBox(height: 32),

            // Localized Text Animation
            Column(
                  children: [
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.splashTagline.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                )
                .animate(delay: 600.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
