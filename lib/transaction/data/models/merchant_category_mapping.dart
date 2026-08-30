import 'dart:convert';

import 'package:budget_wise/shared/utils/sms_text_normalizer.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:uuid/uuid.dart';

class MerchantCategoryMapping {
  final String id;
  final String userId;
  final String merchantName;
  final String normalizedMerchantName;
  final String categoryId;
  final String categoryTitle;
  final TransactionType transactionType;
  final int useCount;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MerchantCategoryMapping({
    required this.id,
    this.userId = '',
    required this.merchantName,
    required this.normalizedMerchantName,
    required this.categoryId,
    required this.categoryTitle,
    required this.transactionType,
    this.useCount = 1,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantCategoryMapping.create({
    required String merchantName,
    required String categoryId,
    required String categoryTitle,
    required TransactionType transactionType,
    String userId = '',
  }) {
    final now = DateTime.now();
    return MerchantCategoryMapping(
      id: const Uuid().v4(),
      userId: userId,
      merchantName: merchantName,
      normalizedMerchantName: normalizeMerchant(merchantName),
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      transactionType: transactionType,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String normalizeMerchant(String merchantName) =>
      SmsTextNormalizer.normalizeForSearch(merchantName);

  bool matchesMerchant(String merchantName) {
    final other = normalizeMerchant(merchantName);
    if (other.isEmpty || normalizedMerchantName.isEmpty) return false;
    if (other == normalizedMerchantName) return true;

    const minSubstringLength = 5;
    if (other.length >= minSubstringLength &&
        normalizedMerchantName.length >= minSubstringLength &&
        (other.contains(normalizedMerchantName) ||
            normalizedMerchantName.contains(other))) {
      return true;
    }

    return normalizedMerchantName.similarityTo(other) >= 0.86;
  }

  MerchantCategoryMapping incrementUse({
    required String categoryId,
    required String categoryTitle,
    required TransactionType transactionType,
    String? userId,
  }) {
    return copyWith(
      userId: userId ?? this.userId,
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      transactionType: transactionType,
      useCount: useCount + 1,
      isSynced: false,
      updatedAt: DateTime.now(),
    );
  }

  MerchantCategoryMapping copyWith({
    String? id,
    String? userId,
    String? merchantName,
    String? normalizedMerchantName,
    String? categoryId,
    String? categoryTitle,
    TransactionType? transactionType,
    int? useCount,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantCategoryMapping(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantName: merchantName ?? this.merchantName,
      normalizedMerchantName:
          normalizedMerchantName ?? this.normalizedMerchantName,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      transactionType: transactionType ?? this.transactionType,
      useCount: useCount ?? this.useCount,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'merchantName': merchantName,
      'normalizedMerchantName': normalizedMerchantName,
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'transactionType': transactionType.name,
      'useCount': useCount,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MerchantCategoryMapping.fromMap(Map<String, dynamic> map) {
    return MerchantCategoryMapping(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? '',
      merchantName: map['merchantName'] as String,
      normalizedMerchantName: map['normalizedMerchantName'] as String,
      categoryId: map['categoryId'] as String,
      categoryTitle: map['categoryTitle'] as String,
      transactionType: TransactionType.values.firstWhere(
        (type) => type.name == map['transactionType'],
      ),
      useCount: map['useCount'] as int? ?? 1,
      isSynced: map['isSynced'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory MerchantCategoryMapping.fromJson(String source) =>
      MerchantCategoryMapping.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
