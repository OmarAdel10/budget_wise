// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AccountType { cash, card }

class AccountModel {
  String id;
  String userId;
  final AccountType accountType;
  final String title;
  final IconData accountIcon;
  final double initialBalance;
  final double balance;
  final String currency;
  final String? cardBankName;
  final String? cardNumber;
  final String? cardExpiryDate;
  final CardBrand? cardBrand;
  final DateTime createdAt;
  bool isSynced;

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
    this.cardNumber = '',
    this.cardExpiryDate = '',
    this.cardBrand = CardBrand.visa,
    required this.createdAt,
    this.isSynced = false,
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
    String? cardNumber,
    String? cardExpiryDate,
    CardBrand? cardBrand,
    DateTime? createdAt,
    bool? isSynced,
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
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiryDate: cardExpiryDate ?? this.cardExpiryDate,
      cardBrand: cardBrand ?? this.cardBrand,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
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
      'cardNumber': cardNumber,
      'cardExpiryDate': cardExpiryDate,
      'cardBrand': cardBrand?.name,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
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
      cardNumber: map['cardNumber'] != null
          ? map['cardNumber'] as String
          : null,
      cardExpiryDate: map['cardExpiryDate'] != null
          ? map['cardExpiryDate'] as String
          : null,
      cardBrand: map['cardBrand'] != null
          ? CardBrand.values.firstWhere((e) => e.name == map['cardBrand'])
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      isSynced: map['isSynced'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountModel.fromJson(String source) =>
      AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
