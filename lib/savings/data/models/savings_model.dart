// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsModel {
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
  });

  bool get isCompleted => currentAmount >= targetAmount;

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
    );
  }

  String toJson() => json.encode(toMap());

  factory SavingsModel.fromJson(String source) =>
      SavingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
