import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:budget_wise/shared/constants/colors.dart';

class InitializationLoadingScreen extends StatelessWidget {
  static const String routeName = '/initialization-loading';

  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> statusNotifier;

  const InitializationLoadingScreen({
    super.key,
    required this.progressNotifier,
    required this.statusNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryAccent,
              size: 50,
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<String>(
              valueListenable: statusNotifier,
              builder: (context, status, _) => Text(
                status,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, progress, _) => Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.secondaryBackground,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
