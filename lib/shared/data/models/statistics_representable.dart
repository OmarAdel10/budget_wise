import 'package:flutter/material.dart';

abstract class FinancialRepresentable {
  String get financialId;
  String get financialTitle;
  IconData get financialIcon;
  Color? get financialColor;
}
