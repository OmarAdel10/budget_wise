import 'package:flutter/material.dart';
import '../../../shared/constants/spacing.dart';

class TransactionTypeEmptyState extends StatelessWidget {
  final String message;

  const TransactionTypeEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
