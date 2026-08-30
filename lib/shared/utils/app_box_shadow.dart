import 'package:flutter/material.dart';

class AppBoxShadow extends BoxShadow {
  AppBoxShadow({
    super.offset = const Offset(0, 5),
    super.blurRadius = 5.0,
    super.spreadRadius = 1.0,
    Color? color,
  }) : super(color: color ?? Colors.black.withValues(alpha: 0.2));
}
