import 'dart:convert';
import 'package:budget_wise/shared/data/models/statistics_representable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SavingsMethod {
  defaultPattern, // $1, $2, $3...
  constant, // $X every day
  doublePattern, // $2, $4, $6...
  custom, // Manual entries
}

class SavingsModel implements FinancialRepresentable {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime targetDate;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final List<int> completedDays;
  final SavingsMethod method;
  final double? constantAmount; // For Constant Method
  final Map<int, double> customAmounts; // For Custom Method (Day -> Amount)
  final int targetDays;
  final Map<int, DateTime> contributionDates; // Day index -> Date completed
  final String sourceAccountId;
  final String savingAccountId;

  SavingsModel({
    this.id = '',
    this.userId = '',
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.currency,
    required this.targetDate,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.completedDays = const [],
    this.contributionDates = const {},
    required this.method,
    this.constantAmount,
    this.customAmounts = const {},
    required this.targetDays,
    this.sourceAccountId = '',
    this.savingAccountId = '',
  });

  @override
  String get financialId => id;

  @override
  String get financialTitle => name;

  @override
  IconData get financialIcon => PhosphorIconsBold.tipJar;

  @override
  Color? get financialColor => Color(colorValue);

  bool get isCompleted => currentAmount >= targetAmount;

  bool get isBehindSchedule {
    if (isCompleted) return false;
    final now = DateTime.now();
    final totalDays = targetDate.difference(createdAt).inDays;
    final elapsedDays = now.difference(createdAt).inDays;
    
    if (totalDays <= 0 || elapsedDays <= 0) return false;
    
    final expectedAmount = (elapsedDays / totalDays) * targetAmount;
    return currentAmount < (expectedAmount * 0.8);
  }

  double getAmountForDay(int dayNum) {
    switch (method) {
      case SavingsMethod.defaultPattern:
        return dayNum.toDouble();
      case SavingsMethod.doublePattern:
        return dayNum.toDouble() * 2;
      case SavingsMethod.constant:
        return constantAmount ?? 0.0;
      case SavingsMethod.custom:
        return customAmounts[dayNum] ?? 0.0;
    }
  }

  List<int>? _allDaysCache;
  List<int> get allDaysList {
    if (_allDaysCache != null) return _allDaysCache!;
    if (method == SavingsMethod.custom) {
      _allDaysCache = customAmounts.keys.toList()..sort();
    } else {
      _allDaysCache = List.generate(targetDays, (i) => i + 1);
    }
    return _allDaysCache!;
  }

  List<int>? _uncompletedDaysCache;
  List<int> get uncompletedDaysList {
    if (_uncompletedDaysCache != null) return _uncompletedDaysCache!;
    _uncompletedDaysCache = allDaysList
        .where((d) => !completedDays.contains(d))
        .toList();
    return _uncompletedDaysCache!;
  }

  List<int>? _completedDaysCache;
  List<int> get completedDaysList {
    if (_completedDaysCache != null) return _completedDaysCache!;
    _completedDaysCache = allDaysList
        .where((d) => completedDays.contains(d))
        .toList();
    return _completedDaysCache!;
  }

  SavingsModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    List<int>? completedDays,
    Map<int, DateTime>? contributionDates,
    SavingsMethod? method,
    double? constantAmount,
    Map<int, double>? customAmounts,
    int? targetDays,
    String? sourceAccountId,
    String? savingAccountId,
  }) {
    return SavingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      completedDays: completedDays ?? this.completedDays,
      contributionDates: contributionDates ?? this.contributionDates,
      method: method ?? this.method,
      constantAmount: constantAmount ?? this.constantAmount,
      customAmounts: customAmounts ?? this.customAmounts,
      targetDays: targetDays ?? this.targetDays,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      savingAccountId: savingAccountId ?? this.savingAccountId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'targetDate': targetDate.toIso8601String(),
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'completedDays': completedDays,
      'contributionDates': contributionDates.map(
        (k, v) => MapEntry(k.toString(), v.toIso8601String()),
      ),
      'method': method.name,
      'constantAmount': constantAmount,
      'customAmounts': customAmounts.map((k, v) => MapEntry(k.toString(), v)),
      'targetDays': targetDays,
      'sourceAccountId': sourceAccountId,
      'savingAccountId': savingAccountId,
    };
  }

  factory SavingsModel.fromMap(Map<String, dynamic> map) {
    return SavingsModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      currency: map['currency'] as String,
      targetDate: map['targetDate'] is Timestamp
          ? (map['targetDate'] as Timestamp).toDate()
          : DateTime.parse(map['targetDate'] as String),
      colorValue: map['colorValue'] as int,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
      isSynced: map['isSynced'] as bool,
      completedDays: List<int>.from(map['completedDays'] ?? []),
      contributionDates:
          (map['contributionDates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              int.parse(k),
              v is Timestamp ? v.toDate() : DateTime.parse(v as String),
            ),
          ) ??
          {},
      method: SavingsMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => SavingsMethod.defaultPattern,
      ),
      constantAmount: (map['constantAmount'] as num?)?.toDouble(),
      customAmounts:
          (map['customAmounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
          ) ??
          {},
      targetDays: map['targetDays'] as int,
      sourceAccountId: map['sourceAccountId'] as String? ?? '',
      savingAccountId: map['savingAccountId'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SavingsModel.fromJson(String source) =>
      SavingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
