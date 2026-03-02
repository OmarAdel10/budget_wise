import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EmptyPendingSmsView extends StatelessWidget {
  const EmptyPendingSmsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.noPendingSmsTransactions,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
