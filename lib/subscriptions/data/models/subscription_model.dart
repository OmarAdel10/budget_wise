// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:budget_wise/shared/data/models/statistics_representable.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';

class SubscriptionModel implements FinancialRepresentable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String currency;
  final BillingCycle billingCycle;
  final String categoryId;
  final IconData icon;
  final DateTime startDate;
  final int billingDay;
  final DateTime nextBillingDate;
  final DateTime? lastPaidDate;
  final bool isPaused;
  final bool reminderEnabled;
  final int remindBeforeDays;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  String get financialId => id;

  @override
  String get financialTitle => name;

  @override
  IconData get financialIcon => icon;

  @override
  Color? get financialColor => null;

  SubscriptionModel({
    this.id = '',
    this.userId = '',
    required this.name,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.categoryId,
    required this.icon,
    required this.startDate,
    required this.billingDay,
    required this.nextBillingDate,
    this.lastPaidDate,
    this.isPaused = false,
    this.reminderEnabled = true,
    this.remindBeforeDays = 1,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? currency,
    BillingCycle? billingCycle,
    String? categoryId,
    IconData? icon,
    DateTime? startDate,
    int? billingDay,
    DateTime? nextBillingDate,
    DateTime? lastPaidDate,
    bool? isPaused,
    bool? reminderEnabled,
    int? remindBeforeDays,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      billingDay: billingDay ?? this.billingDay,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      isPaused: isPaused ?? this.isPaused,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      remindBeforeDays: remindBeforeDays ?? this.remindBeforeDays,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'currency': currency,
      'billingCycle': billingCycle.name,
      'categoryId': categoryId,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'startDate': startDate.toIso8601String(),
      'billingDay': billingDay,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'lastPaidDate': lastPaidDate?.toIso8601String(),
      'isPaused': isPaused,
      'reminderEnabled': reminderEnabled,
      'remindBeforeDays': remindBeforeDays,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == map['billingCycle'],
      ),
      categoryId: map['categoryId'] as String,
      icon: IconData(
        map['iconCodePoint'] as int,
        fontFamily: map['iconFontFamily'] as String?,
        fontPackage: map['iconFontPackage'] as String?,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      billingDay: map['billingDay'] as int,
      nextBillingDate: DateTime.parse(map['nextBillingDate'] as String),
      lastPaidDate: map['lastPaidDate'] != null
          ? DateTime.parse(map['lastPaidDate'] as String)
          : null,
      isPaused: map['isPaused'] as bool,
      reminderEnabled: map['reminderEnabled'] as bool,
      remindBeforeDays: map['remindBeforeDays'] as int,
      isSynced: map['isSynced'] as bool,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
