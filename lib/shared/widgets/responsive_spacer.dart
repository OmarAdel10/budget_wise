import 'package:flutter/material.dart';

class ResponsiveSpacer extends StatelessWidget {
  final double heightFraction;

  const ResponsiveSpacer({super.key, required this.heightFraction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.sizeOf(context).height * heightFraction);
  }
}
