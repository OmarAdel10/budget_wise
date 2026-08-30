// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/shared/data/models/statistics_representable.dart';

enum StatisticsSourceType { category, savings, subscription }

class FinancialBreakdownItem extends Equatable {
  final FinancialRepresentable source;
  final StatisticsSourceType sourceType;
  final double amount;
  final double percentage;

  const FinancialBreakdownItem({
    required this.source,
    required this.sourceType,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [source, sourceType, amount, percentage];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'source': (source as dynamic).toMap(),
      'sourceType': sourceType.name,
      'amount': amount,
      'percentage': percentage,
    };
  }

  factory FinancialBreakdownItem.fromMap(Map<String, dynamic> map) {
    final sourceType = StatisticsSourceType.values.byName(
      map['sourceType'] as String,
    );
    final sourceData = map['source'] as Map<String, dynamic>;

    final FinancialRepresentable source = switch (sourceType) {
      StatisticsSourceType.category => CategoryModel.fromMap(sourceData),
      StatisticsSourceType.savings => SavingGoalModel.fromMap(sourceData),
      StatisticsSourceType.subscription => SubscriptionModel.fromMap(
        sourceData,
      ),
    };
    return FinancialBreakdownItem(
      source: source,
      sourceType: sourceType,
      amount: (map['amount'] as num).toDouble(),
      percentage: (map['percentage'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FinancialBreakdownItem.fromJson(String source) =>
      FinancialBreakdownItem.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  FinancialBreakdownItem copyWith({
    FinancialRepresentable? source,
    StatisticsSourceType? sourceType,
    double? amount,
    double? percentage,
  }) {
    return FinancialBreakdownItem(
      source: source ?? this.source,
      sourceType: sourceType ?? this.sourceType,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
    );
  }
}
