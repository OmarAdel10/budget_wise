// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AccountType { cash, card, saving }

class AccountModel {
  final String id;
  final String userId;
  final AccountType accountType;
  final String title;
  final IconData accountIcon;
  final double initialBalance;
  final double balance;
  final String currency;
  final String? cardBankName;
  final String? cardHolderName;
  final String? cardNumber;
  final String? cardExpiryDate;
  final CardBrand? cardBrand;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool lowBalanceAlertEnabled;
  final List<String>? smsSenderIds;
  final String? smsIdentifier;
  final double lowBalanceAlertAmount;

  AccountModel({
    this.id = '',
    this.userId = '',
    required this.accountType,
    required this.title,
    required this.accountIcon,
    required this.initialBalance,
    required this.balance,
    required this.currency,
    this.cardBankName = '',
    this.cardHolderName = '',
    this.cardNumber = '',
    this.cardExpiryDate = '',
    this.cardBrand = CardBrand.visa,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lowBalanceAlertEnabled = false,
    this.smsSenderIds,
    this.smsIdentifier,
    this.lowBalanceAlertAmount = 0.0,
  });

  AccountModel copyWith({
    String? id,
    String? userId,
    AccountType? accountType,
    String? title,
    IconData? accountIcon,
    double? initialBalance,
    double? balance,
    String? currency,
    String? cardBankName,
    String? cardHolderName,
    String? cardNumber,
    String? cardExpiryDate,
    CardBrand? cardBrand,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? lowBalanceAlertEnabled,
    List<String>? smsSenderIds,
    String? smsIdentifier,
    double? lowBalanceAlertAmount,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
      title: title ?? this.title,
      accountIcon: accountIcon ?? this.accountIcon,
      initialBalance: initialBalance ?? this.initialBalance,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      cardBankName: cardBankName ?? this.cardBankName,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiryDate: cardExpiryDate ?? this.cardExpiryDate,
      cardBrand: cardBrand ?? this.cardBrand,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lowBalanceAlertEnabled:
          lowBalanceAlertEnabled ?? this.lowBalanceAlertEnabled,
      smsSenderIds: smsSenderIds ?? this.smsSenderIds,
      smsIdentifier: smsIdentifier ?? this.smsIdentifier,
      lowBalanceAlertAmount:
          lowBalanceAlertAmount ?? this.lowBalanceAlertAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'accountType': accountType.name,
      'title': title,
      'accountIconCodePoint': accountIcon.codePoint,
      'accountIconFontFamily': accountIcon.fontFamily,
      'accountIconFontPackage': accountIcon.fontPackage,
      'initialBalance': initialBalance,
      'balance': balance,
      'currency': currency,
      'cardBankName': cardBankName,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'cardExpiryDate': cardExpiryDate,
      'cardBrand': cardBrand?.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'lowBalanceAlertEnabled': lowBalanceAlertEnabled,
      'smsSenderIds': smsSenderIds,
      'smsIdentifier': smsIdentifier,
      'lowBalanceAlertAmount': lowBalanceAlertAmount,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      accountType: AccountType.values.firstWhere(
        (e) => e.name == map['accountType'],
      ),
      title: map['title'] as String,
      accountIcon: IconData(
        map['accountIconCodePoint'] as int,
        fontFamily: map['accountIconFontFamily'] as String?,
        fontPackage: map['accountIconFontPackage'] as String?,
      ),
      initialBalance: map['initialBalance'] as double,
      balance: map['balance'] as double,
      currency: map['currency'] as String,
      cardBankName: map['cardBankName'] != null
          ? map['cardBankName'] as String
          : null,
      cardHolderName: map['cardHolderName'] != null
          ? map['cardHolderName'] as String
          : null,
      cardNumber: map['cardNumber'] != null
          ? map['cardNumber'] as String
          : null,
      cardExpiryDate: map['cardExpiryDate'] != null
          ? map['cardExpiryDate'] as String
          : null,
      cardBrand: map['cardBrand'] != null
          ? CardBrand.values.firstWhere(
              (e) => e.name == map['cardBrand'],
              orElse: () => CardBrand.mastercard,
            )
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
      isSynced: map['isSynced'] as bool,
      lowBalanceAlertEnabled: map['lowBalanceAlertEnabled'] ?? false,
      smsSenderIds: (map['smsSenderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      smsIdentifier: map['smsIdentifier'] as String?,
      lowBalanceAlertAmount:
          (map['lowBalanceAlertAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountModel.fromJson(String source) =>
      AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
